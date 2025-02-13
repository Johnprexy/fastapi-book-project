# Dockerfile
FROM python:3.9-slim

# Install nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Configure nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /etc/nginx/conf.d/default.conf /etc/nginx/sites-enabled/

# Create start script
RUN echo '#!/bin/bash\n\
nginx\n\
uvicorn main:app --host 127.0.0.1 --port 8000\n'\
> /app/start.sh && chmod +x /app/start.sh

# Expose port 80
EXPOSE 80

# Start both nginx and uvicorn
CMD ["/app/start.sh"]
