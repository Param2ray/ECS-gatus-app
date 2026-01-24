# Stage 1: Build Stage

FROM python:3.8-slim AS build

WORKDIR /health

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Run Stage

FROM python:3.8-alpine

WORKDIR /health

COPY --from=build /install /usr/local

COPY health.py .

RUN adduser -D -h /home/myuser myuser

USER myuser

EXPOSE 8080

CMD ["python", "health.py"]