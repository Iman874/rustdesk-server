# Gunakan image Rust
FROM rust:latest

# Buat direktori untuk aplikasi
WORKDIR /app

# Salin semua file ke dalam container
COPY . .

# Install dependencies dan build
RUN cargo build --release

# Jalankan server dengan port yang disesuaikan
CMD ["./target/release/rustdesk-server"]
