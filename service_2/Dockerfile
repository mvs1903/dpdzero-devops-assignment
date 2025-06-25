FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy source files
COPY . .

# Install curl as root
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Install Python deps as root
RUN pip install --no-cache-dir flask==3.1.1

#  Add non-root user and switch
RUN useradd -m appuser
USER appuser


# Expose port used by Flask app
EXPOSE 8002

# Run the app
CMD ["python", "app.py"]
