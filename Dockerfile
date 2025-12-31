# Stage 1: Build Stage

FROM python:3.8-slim AS build

WORKDIR /health

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Stage 2: Production Stage

FROM python:3.8-slim

WORKDIR /health

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

RUN adduser nonroot && chown -R nonroot:nonroot /health

USER nonroot

COPY --from=build /health /health

EXPOSE 80

CMD ["python", "health.py"]

