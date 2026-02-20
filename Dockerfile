# Stage 1: Build stage
FROM node:24-alpine AS build

# Tentukan direktori kerja
WORKDIR /app

# Salin package.json dan package-lock.json terlebih dahulu
# Ini memanfaatkan layer caching agar 'npm install' tidak jalan ulang jika tidak ada perubahan package
COPY package*.json ./

# Install dependensi (termasuk devDependencies jika diperlukan untuk build)
RUN npm install

# Salin seluruh kode sumber
COPY . .

# Jika kamu punya langkah build (seperti TypeScript), jalankan di sini:
# RUN npm run build

# ---

# Stage 2: Production stage
FROM node:24-alpine AS runner

WORKDIR /app

# Set environment ke production
ENV NODE_ENV=production

# Hanya salin file yang diperlukan dari stage build
COPY --from=build /app/package*.json ./
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app ./

# Expose port yang digunakan aplikasi (sesuaikan jika bukan 3000)
EXPOSE 3000

# Jalankan aplikasi
# Menggunakan 'node server.js' biasanya lebih ringan daripada 'npm start' di production
CMD ["node", "server.js"]
