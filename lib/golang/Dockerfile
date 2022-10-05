FROM golang:alpine3.16 as builder

WORKDIR /src
COPY . /src
RUN CGO_ENABLED=0 GOOS=linux GOPROXY=https://proxy.golang.org go build -o worker worker.go

FROM alpine:3.16
# mailcap adds mime detection and ca-certificates help with TLS (basic stuff)
RUN apk --no-cache add ca-certificates mailcap && addgroup -S app && adduser -S app -G app
USER app
WORKDIR /app
VOLUME /app/var
COPY --from=builder /src/worker .
ENTRYPOINT ["./worker"]
