# Use a minimal Go image
FROM golang:1.21-alpine

# Set working directory inside container
WORKDIR /app

# Copy Go code into container
COPY main.go .

# Init go module
RUN go mod init service1 && go mod tidy || true

# Installing  curl for healthcheck
RUN apk add --no-cache curl

# Build the Go binary
RUN go build -o main .

# Expose the internal app port
EXPOSE 8001

# Run the app
CMD ["./main"]
