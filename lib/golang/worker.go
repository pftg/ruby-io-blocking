package main

import (
	"crypto/tls"
	"fmt"
	"net/http"
	"os"
	"runtime"
	"strings"
	"sync"
	"time"
)

// Job - interface for job processing
type Job interface {
	Process() Result
}

type Result struct {
	url     string
	status  string
	elapsed time.Duration
	message string
}

// Worker - the worker threads that actually process the jobs
type Worker struct {
	done             sync.WaitGroup
	readyPool        chan chan Job
	assignedJobQueue chan Job
	results          chan Result

	quit chan bool
}

// JobQueue - a queue for enqueueing jobs to be processed
type JobQueue struct {
	internalQueue chan Job
	readyPool     chan chan Job
	results       chan Result

	workers           []*Worker
	dispatcherStopped sync.WaitGroup
	workersStopped    sync.WaitGroup
	quit              chan bool
}

// NewJobQueue - creates a new job queue
func NewJobQueue(maxWorkers int) *JobQueue {
	workersStopped := sync.WaitGroup{}
	readyPool := make(chan chan Job, maxWorkers)
	workers := make([]*Worker, maxWorkers, maxWorkers)
	results := make(chan Result, maxWorkers)

	for i := 0; i < maxWorkers; i++ {
		workers[i] = NewWorker(readyPool, workersStopped, results)
	}
	return &JobQueue{
		internalQueue:     make(chan Job),
		readyPool:         readyPool,
		workers:           workers,
		results:           results,
		dispatcherStopped: sync.WaitGroup{},
		workersStopped:    workersStopped,
		quit:              make(chan bool),
	}
}

// Start - starts the worker routines and dispatcher routine
func (q *JobQueue) Start() {
	for i := 0; i < len(q.workers); i++ {
		q.workers[i].Start()
	}
	go q.dispatch()
}

// Stop - stops the workers and dispatcher routine
func (q *JobQueue) Stop() {
	q.quit <- true
	q.dispatcherStopped.Wait()
}

func (q *JobQueue) dispatch() {
	q.dispatcherStopped.Add(1)
	for {
		select {
		case job := <-q.internalQueue: // We got something in on our queue
			// fmt.Println("Get next job")

			workerChannel := <-q.readyPool // Check out an available worker
			workerChannel <- job           // Send the request to the channel
		case <-q.quit:
			// fmt.Println("To stop workers")

			for i := 0; i < len(q.workers); i++ {
				q.workers[i].Stop()
			}
			close(q.results)
			q.workersStopped.Wait()
			q.dispatcherStopped.Done()
			return
		}
	}
}

// Submit - adds a new job to be processed
func (q *JobQueue) Submit(job Job) {
	q.internalQueue <- job
}

// NewWorker - creates a new worker
func NewWorker(readyPool chan chan Job, done sync.WaitGroup, results chan Result) *Worker {
	return &Worker{
		done:             done,
		readyPool:        readyPool,
		results:          results,
		assignedJobQueue: make(chan Job),
		quit:             make(chan bool),
	}
}

// Start - begins the job processing loop for the worker
func (w *Worker) Start() {
	go func() {
		w.done.Add(1)
		for {
			w.readyPool <- w.assignedJobQueue // check the job queue in
			select {
			case job := <-w.assignedJobQueue: // see if anything has been assigned to the queue
				// fmt.Println("Process job")

				w.results <- job.Process()
				//fmt.Printf("Len Results: %d\n", len(w.results))
			case <-w.quit:
				// fmt.Println("Worker Quit")
				w.done.Done()
				return
			}
		}
	}()
}

// Stop - stops the worker
func (w *Worker) Stop() {
	w.quit <- true
}

//////////////// Example //////////////////

// TestJob - holds only an ID to show state
type TestJob struct {
	url string
}

// Process - test process function
func (t *TestJob) Process() Result {
	tr := &http.Transport{
		TLSClientConfig: &tls.Config{InsecureSkipVerify: true},
	}

	c := &http.Client{
		Timeout:   10 * time.Second,
		Transport: tr,
	}

	req, err := http.NewRequest("GET", t.url, nil)
	req.Header.Add("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9")
	req.Header.Add("Accept-Encoding", "gzip, deflate, br")
	req.Header.Add("Accept-Language", "en-US,en;q=0.9,ru;q=0.8,uk;q=0.7,de;q=0.6")
	req.Header.Add("User-Agent", "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1")
	req.Header.Add("pragma", "no-cache")
	req.Header.Add("cache-control", "no-cache")

	start := time.Now()

	res, err := c.Do(req)

	elapsed := time.Since(start)

	//fmt.Printf("Debug: %s\n", elapsed)

	if err != nil {
		return Result{t.url, "false", elapsed, err.Error()}
	} else {
		if res.StatusCode >= 200 && res.StatusCode < 400 {
			return Result{t.url, "true", elapsed, ""}
		} else {
			return Result{t.url, "false", elapsed, fmt.Sprintf("HTTP Response Code: %d", res.StatusCode)}
		}
	}

	return Result{t.url, "false", 0, "No Response"}
}

func main() {
	//runtime.GOMAXPROCS(1)
	runtime.GOMAXPROCS(runtime.NumCPU() * 2)

	pwd, _ := os.Getwd()
	var fileName string

	if len(os.Args) > 1 {
		fileName = os.Args[1]
	} else {
		fileName = "lib/fixtures/httpbin.csv"
	}

	urlsPath := pwd + "/" + fileName

	urlsFileBody, err := os.ReadFile(urlsPath)
	if err != nil {
		panic(err)
	}

	urls := strings.Split(strings.TrimRight(string(urlsFileBody), "\n"), "\n")

	queue := NewJobQueue(runtime.NumCPU() * 200)
	fmt.Printf("Workers Count: %d\n", runtime.NumCPU()*200)
	queue.Start()
	defer queue.Stop()

	go func() {
		queue.dispatcherStopped.Add(1)
		// fmt.Println("Start collecting results")

		f, err := os.OpenFile("result-go.csv", os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0644)
		if err != nil {
			panic(err)
		}

		defer f.Close()

		for {
			select {
			case r, ok := <-queue.results:
				if !ok {
					fmt.Printf("Debug: Got Quit")
					queue.dispatcherStopped.Done()
					return
				}

				line := fmt.Sprintf("%s, %s, %d, %s\n", r.url, r.status, int64(r.elapsed/time.Millisecond), r.message)
				if _, err = f.WriteString(line); err != nil {
					panic(err)
				}
			default:
			}
		}
	}()

	for _, line := range urls {
		queue.Submit(&TestJob{line})
	}
}
