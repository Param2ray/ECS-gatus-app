# Stage 1: Lightweight Build Stage
FROM golang:1.24-alpine AS builder
# Set desitination for COPY instructions
WORKDIR /app
# Copy go.mod and go.sum files
COPY app/go.mod app/go.sum ./
# Download Go module dependencies
RUN go mod download
# Copy the source code
COPY app/ ./
# Build slimmed down and defined
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/gatus-build
# Clean up unnecessary files
RUN go mod tidy
# Stage 2: Build the application
FROM gcr.io/distroless/static-debian12:nonroot AS release
#  Set environment variable for config path
ENV GATUS_CONFIG_PATH=/config/config.yaml
# Set working directory
WORKDIR /app
#Copy into distroless image
COPY --from=builder /app/gatus-build /app/gatus-build
# Expose application port
EXPOSE 8080
# Command to run the application
CMD ["/app/gatus-build"]