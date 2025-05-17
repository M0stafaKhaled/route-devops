# 🚀 FastAPI Application with PostgreSQL, Redis, and Nginx

This project demonstrates a containerized **FastAPI** application integrated with **PostgreSQL**, **Redis**, and **Nginx**, orchestrated using **Docker Compose**.

---

## 📌 Features

- **FastAPI**: Modern, high-performance web framework for building APIs.
- **PostgreSQL**: Reliable relational database for persistent data storage.
- **Redis**: In-memory key-value store used for caching.
- **Nginx**: Reverse proxy server routing traffic to FastAPI.
- **Docker Compose**: Simplifies multi-container setup and orchestration.

---

## 🧰 Prerequisites

- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)

---

## ⚙️ Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd <repository-directory>
```

### 2. Build and Start the Containers

```bash
docker-compose up --build
```

### 3. Access the Application

- **FastAPI (direct)**: [http://localhost:8000](http://localhost:8000)
- **Nginx (proxy)**: [http://localhost:8081](http://localhost:8081)

### 4. Stop the Containers

```bash
docker-compose down
```

---

## 🧾 Services Overview

### 1. 🟦 FastAPI Application (`app`)
- **Container Name**: `fast_api_container`
- **Port**: `8000`
- **Environment Variables**:
  ```env
  DATABASE_URL=postgresql://postgres:password@db:5432/postgres
  ```

### 2. 🐘 PostgreSQL Database (`db`)
- **Container Name**: `postgres_container`
- **Port**: `5432`
- **Environment Variables**:
  ```env
  POSTGRES_USER=postgres
  POSTGRES_PASSWORD=password
  POSTGRES_DB=postgres
  ```
- **Volume**: `postgres_data` (persists database data)

### 3. 🧠 Redis Cache (`caching`)
- **Container Name**: `redis_container`
- **External Port**: `6370` (mapped to `6379` internally)

### 4. 🌐 Nginx Reverse Proxy (`nginx`)
- **Container Name**: `nginx_container`
- **Port**: `8081`
- **Configuration File**: `./nginx/default.conf`

---

## 🗂️ Project Structure

```
.
├── app/
│   ├── main.py          # FastAPI application entry point
│   ├── models.py        # SQLAlchemy models
│   ├── schemas.py       # Pydantic schemas
│   ├── database.py      # Database connection setup
│   ├── redis_client.py  # Redis client setup
├── nginx/
│   └── default.conf     # Nginx configuration
├── docker-compose.yml   # Docker Compose configuration
├── Dockerfile           # Dockerfile for FastAPI app
├── requirements.txt     # Python dependencies
```

---

## 🧪 Testing Redis

Test Redis connectivity via the `/test-redis` endpoint:

```http
GET /test-redis
```

**Expected Response**:
```json
{"message": "Redis is working!"}
```

---

## 🛠️ Troubleshooting

### 1. Database Connection Issues
- Ensure the `db` service is running and healthy.
- Check logs:
  ```bash
  docker-compose logs db
  ```

### 2. Redis Issues
- Use the `/test-redis` endpoint to verify Redis.
- Check logs:
  ```bash
  docker-compose logs redis
  ```

### 3. Nginx Issues
- Validate Nginx config in `nginx/default.conf`.
- Check logs:
  ```bash
  docker-compose logs nginx
  ```

---

## 🧹 Stopping and Cleaning Up

To stop all containers and remove associated volumes:

```bash
docker-compose down -v
```


