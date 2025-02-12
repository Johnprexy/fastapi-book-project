FROM alpine:3.18

# Install required packages
RUN apk add --no-cache \
    python3 \
    py3-pip \
    nginx

# Set the working directory
WORKDIR /app

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the application code
COPY . .

# Copy nginx configuration
COPY nginx.conf /etc/nginx/http.d/default.conf

# Create start script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'nginx' >> /start.sh && \
    echo 'python3 -m uvicorn main:app --host 0.0.0.0 --port 8000' >> /start.sh && \
    chmod +x /start.sh

# Expose port 80
EXPOSE 80

# Start both services
CMD ["/start.sh"]