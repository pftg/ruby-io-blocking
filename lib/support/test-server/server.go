package main

import (
	"fmt"
	"net/http"
	"strconv"
	"time"
	"log"
)

func main() {

log.Println("Loading ...")

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		delay := int64(1)
		delayStr := r.URL.Query().Get("delay")

		if s, err := strconv.ParseInt(delayStr, 10, 64); err == nil {
			delay = s
		} else {
			fmt.Printf("Error to parse: %s for %s\n", delayStr, r.URL)
		}

		time.Sleep(time.Millisecond * time.Duration(delay))
		fmt.Fprintf(w, "Hello, you've requested: %s\n", r.URL)
	})


s := &http.Server{
	Addr:           ":9080",
	ReadTimeout:    5 * time.Second,
	WriteTimeout:   5 * time.Second,
}

log.Println(s.ListenAndServe())
}
