FROM python:3.11-slim

# Step 1: Set the working directory
WORKDIR /app

# Step 2: Install system dependencies (as root)
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Step 3: Copy source files (as root)
COPY . .

# Step 4: Install Python packages (as root)
RUN pip install --no-cache-dir flask==3.1.1

# Step 5: Create a non-root user
RUN useradd -m -s /bin/bash appuser

# Step 6: Fix ownership after everything is copied and installed
RUN chown -R appuser:appuser /app

# Step 7: Switch to non-root user
USER appuser

EXPOSE 8002

CMD ["python", "app.py"]
