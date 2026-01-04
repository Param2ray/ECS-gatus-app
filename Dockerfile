# Stage 1: Build Stage

FROM python:3.8-slim AS build
WORKDIR /health
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# Stage 2: Production Stage

FROM python:3.8-slim
WORKDIR /health
COPY --from=build /install /usr/local
COPY health.py .
RUN useradd --user-group --system --no-log-init --create-home myuser
RUN chown -R myuser:myuser /home/myuser
USER myuser
EXPOSE 8080
CMD ["python", "health.py"]