# Stage One Build Application
FROM golang:1.16 AS builder

# Check for go existance and placing code to new dir
RUN go version
WORKDIR /go/src/github.com/instabug/goviolin/app
COPY . /go/src/github.com/instabug/goviolin/app

# Set variables and run application
RUN go env -w GO111MODULE=auto
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -o main .

# Stage Two Minimize Image Size
FROM scratch

# Create dir and copy the binary file into new image
WORKDIR /root/
COPY --from=builder /go/src/github.com/instabug/goviolin/app .

# Port indentification
EXPOSE 8080

# Run binary file
CMD ["./main"]