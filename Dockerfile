# Stage 1: Build the FastAPI application
FROM python:3.9-slim as fastapi

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

# Stage 2: Serve the application using Nginx
FROM nginx:alpine

# Install supervisord
RUN apk add --no-cache supervisor

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the FastAPI app from the previous stage
COPY --from=fastapi /app /app

# Copy supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose port 80 for Nginx
EXPOSE 80

# Start supervisord
CMD ["supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]