# --- TAHAP 1: BUILD ---
# Tahap ini akan meng-install SEMUA dependencies (termasuk dev)
# dan menjalankan skrip build Anda.
FROM oven/bun:latest AS build
WORKDIR /app

# Salin file package
COPY package.json bun.lock ./

# Install SEMUA dependencies (termasuk devDependencies untuk build)
RUN bun install

# Salin sisa kode sumber
COPY src/ ./src/
COPY tsconfig.json ./

# JALANKAN BUILD SCRIPT ANDA
# Ini akan membuat folder /app/dist/server.js
RUN bun run build

# --- TAHAP 2: RILIS ---
# Tahap ini adalah image produksi akhir yang ramping.
FROM oven/bun:latest

WORKDIR /app

# Salin file package lagi
COPY package.json bun.lock ./

# Install HANYA dependencies produksi
RUN bun install --production

# Salin HANYA folder 'dist' yang sudah di-build dari tahap 'build'
COPY --from=build /app/dist ./dist

EXPOSE 3000

# Sekarang file ini ada, dan CMD Anda akan berhasil
CMD ["bun", "dist/server.js"]
