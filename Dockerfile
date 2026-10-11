# ==============================================================================
# OmniRoute Flow - Production Dockerfile (Optimized for Cloud Deployment)
# ==============================================================================

# --- Builder Stage ---
FROM node:22-bookworm-slim AS builder
WORKDIR /app

# Install dependencies required for native modules (better-sqlite3)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    libsecret-1-0 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV NPM_CONFIG_LEGACY_PEER_DEPS=true
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_OPTIONS="--max-old-space-size=2048"

# Copy package manifests and all build scripts needed by postinstall
COPY package*.json ./
COPY open-sse/package.json ./open-sse/package.json
COPY scripts ./scripts

# Install dependencies (runs postinstall which has all scripts available)
RUN npm install --prefer-offline --no-audit

# Copy application source code
COPY . .

# Build the Next.js application
RUN npm run build

# --- Runner Stage ---
FROM node:22-bookworm-slim AS runner
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    libsecret-1-0 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=10000
ENV DATA_DIR=/root/.omniroute
ENV REQUIRE_API_KEY=true

# Copy built application from builder
COPY --from=builder /app /app

EXPOSE 10000 20128

CMD ["npm", "start"]
