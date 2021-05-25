# Stage One
FROM golang:1.16 AS builder
RUN go version
WORKDIR /go/src/github.com/instabug/goviolin/app
COPY . /go/src/github.com/instabug/goviolin/app
RUN go env -w GO111MODULE=auto
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o main .
# Stage Two
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/github.com/instabug/goviolin/app .
EXPOSE 8080
CMD ["./main"]