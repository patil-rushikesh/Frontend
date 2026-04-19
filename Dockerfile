# Stage 1: Build static assets
FROM node:20-alpine AS builder

WORKDIR /app

# Use Corepack to get a pinned pnpm from lockfile metadata.
RUN corepack enable

# Copy dependency manifests first for better layer cache reuse.
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm install --frozen-lockfile

# Copy source and create production build.
COPY . .
RUN pnpm run build

# Stage 2: Serve build with Nginx
FROM nginx:1.27-alpine

# Replace default site config with Cloud Run + SPA-friendly config.
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built static files from builder.
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 8080

# Generate env-config.js using Cloud Run runtime variables, then start Nginx
CMD ["/bin/sh", "-c", "\
    echo 'window._env_ = {' > /usr/share/nginx/html/env-config.js && \
    echo \"  VITE_API_BASE_URL: '${VITE_API_BASE_URL}',\" >> /usr/share/nginx/html/env-config.js && \
    echo \"  VITE_BACKEND_BASE_URL: '${VITE_BACKEND_BASE_URL}',\" >> /usr/share/nginx/html/env-config.js && \
    echo \"  VITE_PAYMENT_MODE: '${VITE_PAYMENT_MODE}',\" >> /usr/share/nginx/html/env-config.js && \
    echo \"  VITE_RAZORPAY_KEY_ID: '${VITE_RAZORPAY_KEY_ID}',\" >> /usr/share/nginx/html/env-config.js && \
    echo \"  VITE_ENABLE_QA_TOOLS: '${VITE_ENABLE_QA_TOOLS}'\" >> /usr/share/nginx/html/env-config.js && \
    echo '};' >> /usr/share/nginx/html/env-config.js && \
    nginx -g 'daemon off;' \
"]