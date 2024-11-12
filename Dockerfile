# Gunakan image dasar dari Rust untuk membangun server
FROM rust:latest AS builder

# Buat direktori kerja
WORKDIR /app

# Salin file Cargo.toml dan Cargo.lock ke direktori kerja untuk dependency
COPY Cargo.toml Cargo.lock ./

# Unduh dan kompilasi dependency tanpa sumber kode
RUN cargo fetch

# Salin seluruh kode sumber ke dalam direktori kerja
COPY . .

# Kompilasi RustDesk server dalam mode release
RUN cargo build --release

# Tahap kedua: Gunakan image yang lebih kecil untuk runtime
FROM debian:buster-slim

# Instal dependency yang diperlukan untuk menjalankan RustDesk server
RUN apt-get update && \
    apt-get install -y libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Buat direktori kerja untuk server di tahap runtime
WORKDIR /app

# Salin executable yang telah dikompilasi dari tahap build
COPY --from=builder /app/target/release/rustdesk-server /app/rustdesk-server

# Ekspose port relay dan port rendezvous
EXPOSE 21114 21115

# Jalankan server dengan perintah default
CMD ["./rustdesk-server"]
