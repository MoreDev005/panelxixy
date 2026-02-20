# Stage 1: Build stage
FROM node:24-alpine AS build

# 1. Install dependencies untuk native modules (node-gyp, node-pty, dll)
# Kita butuh python3, make, dan g++ untuk proses build.
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    gcc \
    linux-headers

WORKDIR /app

# 2. Copy package files
COPY package*.json ./

# 3. Install SEMUA dependencies (termasuk devDeps untuk build)
RUN npm install

# 4. Copy seluruh source code
COPY . .

# 5. Opsional: Hapus devDependencies setelah build untuk menghemat ruang
# RUN npm prune --production

# ---

# Stage 2: Production stage (Image Akhir)
FROM node:24-alpine AS runner

# Tentukan direktori kerja
WORKDIR /app

# Set environment ke production
ENV NODE_ENV=production

# 6. Salin file dari stage build
# Kita salin semua karena node-pty butuh binary yang sudah di-compile di stage 1
COPY --from=build /app ./

# 7. Expose port (sesuaikan dengan aplikasi kamu)
EXPOSE 8000

# 8. Jalankan aplikasi
# Menggunakan 'node' langsung jauh lebih hemat RAM dibanding 'npm start'
CMD ["node", "server.js"]
