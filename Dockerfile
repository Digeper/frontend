# Multi-stage build for MuzikaPlayer frontend
# Stage 1: Build the Vue.js application (optional - can use pre-built dist)
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files if they exist
COPY package*.json ./
RUN npm ci --only=production || true

# Copy source files
COPY . .

# Build the application (if dist doesn't exist or needs rebuilding)
# Uncomment if you want to build in Docker
# RUN npm run build

# Stage 2: Serve with nginx
FROM nginx:alpine

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built static files from dist folder
COPY dist/ /usr/share/nginx/html/

# Create a non-root user for nginx
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
