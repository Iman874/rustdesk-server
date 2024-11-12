# Tahap builder untuk membangun binary secara statis
FROM rust:latest as builder

# Install dependencies untuk musl (untuk kompilasi statis)
RUN apt-get update && apt-get install -y musl-tools

# Atur direktori kerja
WORKDIR /app

# Salin file Cargo dan source code
COPY Cargo.toml Cargo.lock ./
COPY src ./src

# Atur target musl untuk binary statis dan compile
RUN rustup target add x86_64-unknown-linux-musl
RUN cargo build --release --target=x86_64-unknown-linux-musl

# Tahap final, untuk menyalin hasil binary yang sudah dikompilasi ke dalam image ringan
FROM alpine:latest

# Install OpenSSL dan library pendukung jika diperlukan
RUN apk add --no-cache openssl

# Salin binary dari tahap builder
COPY --from=builder /app/target/x86_64-unknown-linux-musl/release/hbbr /usr/local/bin/hbbr

# Set environment variable yang diperlukan
ENV RUST_BACKTRACE=1

# Tentukan port aplikasi
EXPOSE 21115

# Jalankan aplikasi
CMD ["hbbr"]
