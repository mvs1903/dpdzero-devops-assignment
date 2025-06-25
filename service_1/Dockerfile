# Use minimal Go base image
FROM golang:1.21-alpine

# Step 1: Set working directory
WORKDIR /app

# Step 2: Install system packages (as root)
RUN apk add --no-cache curl

# Step 3: Copy application code (as root)
COPY main.go .

# Step 4: Initialize Go module
RUN go mod init service1 && go mod tidy || true

# Step 5: Build the Go binary
RUN go build -o main .

# Step 6: Create non-root user
RUN adduser -D appuser

# Step 7: Fix permissions so the appuser owns /app
RUN chown -R appuser:appuser /app

# Step 8: Switch to non-root user
USER appuser

# Step 10: Expose app port and run
EXPOSE 8001

CMD ["./main"]
