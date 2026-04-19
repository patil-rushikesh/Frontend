# Stage 1: Build the Vite app
FROM node:20-alpine AS builder

WORKDIR /app
ENV NODE_ENV=development

# Install dependencies first for better layer caching
COPY package*.json ./
RUN npm install --include=dev

# Copy source and build
COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy Nginx config (configured for Cloud Run on port 8080 + SPA routing)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built static files
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
