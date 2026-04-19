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

CMD ["nginx", "-g", "daemon off;"]
