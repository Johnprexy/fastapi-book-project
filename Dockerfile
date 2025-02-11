# Stage 1: Build the FastAPI application
FROM python:3.9-slim AS builder

WORKDIR /app

# Install required system packages
RUN apt-get update && \
    apt-get install -y python3-venv && \
    rm -rf /var/lib/apt/lists/*

# Create and activate virtual environment
RUN python -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir uvicorn

# Copy application files
COPY ./main.py /app/main.py
COPY ./api /app/api
COPY ./core /app/core

# Stage 2: Final image
FROM python:3.9-slim

# Install Nginx and Supervisor
RUN apt-get update && \
    apt-get install -y nginx supervisor && \
    rm -rf /var/lib/apt/lists/*

# Copy the entire app directory including venv from builder
COPY --from=builder /app /app

# Copy configurations
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create necessary directories with proper permissions
RUN mkdir -p /var/log/supervisor /var/run/supervisor /var/log/fastapi \
    && touch /var/log/fastapi.err.log /var/log/fastapi.out.log \
    && chmod -R 777 /var/log/supervisor /var/run/supervisor /var/log/fastapi

# Add virtual environment to PATH
ENV PATH="/app/venv/bin:$PATH"

# Expose port
EXPOSE 80

# Start supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]