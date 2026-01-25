# Stage 1: Build Stage
FROM python:3.12-alpine AS builder

WORKDIR /app

RUN apk add --no-cache gcc musl-dev libffi-dev

COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY app/ app/

# Stage 2: Runtime Stage
FROM python:3.12-alpine

WORKDIR /app

COPY --from=builder /install /usr/local
COPY --from=builder /app /app

RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

EXPOSE 8080

CMD ["python", "app/health.py"]