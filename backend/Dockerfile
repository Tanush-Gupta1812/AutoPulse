# ==========================================
# AutoPulse Backend Multi-Stage Slim Dockerfile
# ==========================================

# Stage 1: Build & wheels
FROM python:3.11-slim-bookworm AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip wheel --no-cache-dir --no-deps --wheel-dir /build/wheels -r requirements.txt

# Stage 2: Production runtime
FROM python:3.11-slim-bookworm AS runner

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -g 1001 appgroup && \
    useradd -u 1001 -g appgroup -s /bin/bash -m appuser

# Install built wheels
COPY --from=builder /build/wheels /wheels
COPY --from=builder /build/requirements.txt .
RUN pip install --no-cache-dir /wheels/* && rm -rf /wheels

# Copy application source & migrations
COPY . /app/backend/
COPY simulator/ /app/simulator/

# Set correct ownership
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 8000

# Entrypoint: wait for DB, run alembic migrations and seed, then launch FastAPI uvicorn
CMD ["sh", "-c", "python -m backend.app.seed && uvicorn backend.app.main:app --host 0.0.0.0 --port 8000"]
