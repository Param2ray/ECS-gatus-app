# Stage 1: Build Stage

FROM gcr.io/distroless/python3

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Run Stage

FROM python:3.8-alpine

WORKDIR /app

COPY --from=build /install /usr/local

COPY app/ ./app/

RUN adduser -D -h /home/myuser myuser

USER myuser

EXPOSE 8080

CMD ["python", "app/health.py"]# trigger pipeline
