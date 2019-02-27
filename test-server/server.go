package main

import (
	"fmt"
	"net/http"
	"strconv"
	"time"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		delay := int64(1)
		delayStr := r.FormValue("delay")

		if s, err := strconv.ParseInt(delayStr, 10, 64); err == nil {
			delay = s
		} else {
			fmt.Printf("Error to parse: %s", delayStr)
		}

		time.Sleep(time.Millisecond * time.Duration(delay))
		fmt.Fprintf(w, "Hello, you've requested: %s\n", r.URL.Path)
	})

	http.ListenAndServe(":9080", nil)
}
