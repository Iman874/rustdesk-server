# Tahap pertama: Build dari Rust source code
FROM rust:latest AS builder

# Buat direktori kerja
WORKDIR /app

# Salin file Cargo.toml dan Cargo.lock ke direktori kerja untuk dependency
COPY Cargo.toml Cargo.lock ./

# Unduh dependency tanpa kode sumber
RUN cargo fetch

# Salin seluruh kode sumber ke dalam direktori kerja
COPY . .

# Kompilasi RustDesk server dalam mode release
RUN cargo build --release --bin hbbr && cargo build --release --bin hbbs

# Tahap kedua: Runtime environment yang lebih kecil
FROM debian:buster-slim

# Install dependency yang diperlukan
RUN apt-get update && \
    apt-get install -y libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Direktori kerja di tahap runtime
WORKDIR /app

# Salin executable yang dikompilasi dari tahap build
COPY --from=builder /app/target/release/hbbs /app/hbbs
COPY --from=builder /app/target/release/hbbr /app/hbbr

# Ekspose port untuk relay dan rendezvous
EXPOSE 21114 21115

# Jalankan server dengan perintah default, bisa diubah sesuai kebutuhan
CMD ["./hbbr", "--relay"]
