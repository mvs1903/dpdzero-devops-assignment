# dpdzero-devops-assignment
Devops Assignment

This project showcases a containerized microservices setup using Docker Compose:

- Two backend services: one in Go (`service_1`) and one in Python (`service_2`)
- Nginx as a reverse proxy to route requests
- Health checks, centralized logging, and non-root users
- Built with production-grade best practices

---

## 📁 Project Structure

```
.
├── docker-compose.yml
├── nginx/
│   ├── nginx.conf
│   └── Dockerfile
├── service_1/               # Golang App
│   ├── main.go
│   └── Dockerfile
├── service_2/               # Flask App
│   ├── app.py
│   ├── pyproject.toml
│   └── Dockerfile
└── README.md
```

---

## 🚀 How to Run the Project

### 1.  **Pre-requisites**

Ensure you have the following installed:

- Docker: https://docs.docker.com/get-docker/
- Docker Compose (v2 or higher): https://docs.docker.com/compose/

---

### 2.  **Run the project**

In the root folder, execute:

```bash
docker-compose up --build
```

---

### 3.  **Access the Services**

Once containers are up:

- Go service:
  - http://localhost:8080/service1/ping
  - http://localhost:8080/service1/hello

- Python (Flask) service:
  - http://localhost:8080/service2/ping
  - http://localhost:8080/service2/hello

---

### 4.  **Stop the services**

To stop and remove containers:

```bash
docker-compose down --volumes
```

---

##  Nginx Reverse Proxy

Nginx runs as a container and handles all routing via path prefixes:

| Path            | Routes To     | Internal Port |
|-----------------|---------------|----------------|
| `/service1`     | Golang app    | 8001           |
| `/service2`     | Python app    | 8002           |

It also logs each request with timestamp and path.

---

##  Health Checks

Both services include a `HEALTHCHECK` in their Dockerfiles to ensure they're running:

- Go App:
  ```bash
  curl http://localhost:8001/ping
  ```
- Flask App:
  ```bash
  curl http://localhost:8002/ping
  ```

Docker will show status as `healthy` via:

```bash
docker ps
```

---

##  Security Best Practices

- Each service runs as a **non-root user (`appuser`)**
- This prevents accidental or malicious system access inside the container
- Confirmed via:
  ```bash
  docker exec -it service_1 whoami   # appuser
  docker exec -it service_2 whoami   # appuser
  ```

- Attempts to write to `/etc` fail, proving limited access:
  ```bash
  touch /etc/test.txt        # Permission denied
  touch /app/test.txt        # ✅ Command Works!
  ```

---

##  Logging

Logs can be viewed via:

```bash
docker-compose logs nginx
```

Sample log:

```
[24/Jun/2025:12:30:00 +0000] "GET /service1/ping HTTP/1.1" 200 ...
```

---

##  Bonus Features

- `curl` installed in both containers to enable internal health checks
- `.dockerignore` can be added for build optimization (if extended)
- Nginx logs include request path and timestamps

---

##  Important Notes

- This setup uses the Flask development server for now. For production, consider switching to **Gunicorn**.
- Docker networking is based on the default `bridge` network.
- All containers expose only required internal ports, with Nginx exposing `8080` externally.

---

##  Conclusion

This project fulfills all stated requirements with additional security, health monitoring, and modular design — following containerization best practices.

