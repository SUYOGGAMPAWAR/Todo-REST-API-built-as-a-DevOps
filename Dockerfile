# ──────────────────────────────────────────────────────────────
#  Stage 1 — Dependencies
# ──────────────────────────────────────────────────────────────
FROM node:20-alpine AS deps

WORKDIR /app

# Copy only package files first (better layer caching)
COPY app/package*.json ./

RUN npm ci --only=production && \
    # Keep a copy of prod deps, then install all for testing
    cp -r node_modules node_modules_prod && \
    npm ci

# ──────────────────────────────────────────────────────────────
#  Stage 2 — Test / CI
# ──────────────────────────────────────────────────────────────
FROM node:20-alpine AS test

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY app/ .

RUN npm run test:ci

# ──────────────────────────────────────────────────────────────
#  Stage 3 — Production image
# ──────────────────────────────────────────────────────────────
FROM node:20-alpine AS production

LABEL maintainer="devops-demo"
LABEL org.opencontainers.image.title="Todo API"
LABEL org.opencontainers.image.description="DevOps Demo — Todo REST API"

# Security: run as non-root
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

WORKDIR /app

# Copy production node_modules (smaller image)
COPY --from=deps /app/node_modules_prod ./node_modules
COPY app/package*.json ./
COPY app/src ./src

# Set ownership
RUN chown -R appuser:appgroup /app

USER appuser

EXPOSE 3000

# Healthcheck used by Docker and Kubernetes probes
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1

CMD ["node", "src/index.js"]
