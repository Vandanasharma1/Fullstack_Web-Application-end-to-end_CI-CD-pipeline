FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install Nginx and dependencies
RUN apt-get update && apt-get install -y nginx curl && rm -rf /var/lib/apt/lists/*

# Copy backend requirements and install
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend and frontend
COPY backend/ /app/backend
COPY frontend/ /var/www/html

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Remove default Nginx config
RUN rm -f /etc/nginx/sites-enabled/default

# Add custom Nginx config
RUN echo 'server { \
    listen 80; \
    server_name _; \
    root /var/www/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    location /api/ { \
        proxy_pass http://127.0.0.1:5000/; \
        proxy_set_header Host $host; \
    } \
}' > /etc/nginx/sites-available/default && \
    ln -s /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Expose ports
EXPOSE 80 5000

# Start Nginx in foreground & Uvicorn backend
WORKDIR /app/backend
CMD nginx -g 'daemon off;' & uvicorn app.main:app --host 0.0.0.0 --port 5000