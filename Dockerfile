# Stage 1: Build stage
FROM node:24-slim AS build

# Install tools yang dibutuhkan untuk meng-compile node-pty
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

# Node-pty butuh akses ke shell dan library dasar Linux.
# Di Debian Slim, ini sudah cukup lengkap, tapi kita pastikan 
# cache apt bersih agar image tetap ringan.
RUN apt-get update && apt-get install -y \
    bash \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV NODE_ENV=production

# Salin semua file dari stage build (termasuk binary node-pty yang sudah jadi)
COPY --from=build /app ./

EXPOSE 8000

# Jalankan langsung
CMD ["node", "server.js"]
