FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy source files
COPY . .

# Install Flask
RUN pip install --no-cache-dir flask==3.1.1

# Install curl for health check
RUN apt-get update && apt-get install -y curl

# Expose port used by Flask app
EXPOSE 8002

# Run the app
CMD ["python", "app.py"]
