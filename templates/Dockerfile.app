# Dockerfile.app — Multi-Stage Production Dockerfile Template
#
# Purpose: Produces a minimal, secure production image using multi-stage build.
#          Stage 1 (builder) compiles/packages the application.
#          Stage 2 (runtime) contains only the final artifact.
# Usage:   docker build -t my-app:1.0.0 -f Dockerfile.app .

# ─────────────────────────────────────────────────────────────────────────────
# Stage 1: Build
# ─────────────────────────────────────────────────────────────────────────────
ARG NODE_VERSION=20
FROM node:${NODE_VERSION} AS builder

WORKDIR /build

# Copy dependency manifests and install
COPY package*.json ./
RUN npm ci --only=production

# Copy source code and build
COPY src/ ./src/
RUN npm run build    # Replace with your actual build command

# ─────────────────────────────────────────────────────────────────────────────
# Stage 2: Runtime
# ─────────────────────────────────────────────────────────────────────────────
FROM node:${NODE_VERSION}-alpine AS runtime

# Create non-root user (security best practice — see security_rules.md)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy only the production artifacts from the builder stage
COPY --from=builder --chown=appuser:appgroup /build/dist ./dist
COPY --from=builder --chown=appuser:appgroup /build/node_modules ./node_modules

# Switch to non-root user
USER appuser

# Expose application port
EXPOSE 3000

# Health check (required — see docker_rules.md)
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1

# Start the application
CMD ["node", "dist/index.js"]
