# Stage 1: Lightweight Build Stage
FROM golang:1.24-alpine AS builder

WORKDIR /app

COPY app/go.mod app/go.sum ./

RUN go mod download

COPY app/ ./

RUN CGO_ENABLED=0 GOOS=linux go build -o /app/gatus-build

RUN go mod tidy


# Stage 2: Build the application
FROM gcr.io/distroless/static-debian12:nonroot AS release

ENV GATUS_CONFIG_PATH=/config/config.yaml

WORKDIR /app

COPY --from=builder /app/gatus-build /app/gatus-build

COPY config/config.yaml /config/config.yaml

EXPOSE 8080

CMD ["/app/gatus-build"]