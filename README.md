# Ecs-Production-Healthcheck-Service

### This project is part of an end-to-end ECS deployment exercise.
The first step focuses on building and validating a minimal application
before containerisation and cloud deployment.

## Step 1 – Local Application Validation

A lightweight Flask application exposing a `/health` endpoint.

### Health Endpoint
- Route: `/health`
- Response:
```json
{"status":"ok"}

python health.py
curl http://localhost:5002/health

{"status":"ok"}

ECS-gatus-app/
├── health.py
├── README.md
├── .gitignore
