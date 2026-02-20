# Stage 1: Build stage
FROM node:24-slim AS build

# Install build tools di Debian Slim
RUN apt-get update && apt-get install -y \
    python3 \
    make \
    g++ \
    gcc \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# ---

# Stage 2: Production stage
FROM node:24-slim AS runner

# Di Debian Slim, kita tetap install sedikit library dasar 
# supaya node-pty bisa panggil shell dengan lancar
RUN apt-get update && apt-get install -y \
    shasum \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV NODE_ENV=production

# Salin semua hasil build
COPY --from=build /app ./

EXPOSE 8000

CMD ["node", "server.js"]
