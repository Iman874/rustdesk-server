# Tahap builder untuk membangun binary
FROM rust:latest as builder

# Atur direktori kerja
WORKDIR /app

# Salin file Cargo dan source code
COPY Cargo.toml Cargo.lock ./
COPY src ./src

# Jalankan cargo build tanpa release untuk debugging
RUN cargo build --verbose

# Jika build berhasil, lanjutkan ke release build
RUN cargo build --release

# Tahap final untuk membuat image runtime yang ringan
FROM ubuntu:latest

# Install dependencies yang dibutuhkan untuk menjalankan binary
RUN apt-get update && \
    apt-get install -y libssl-dev ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Salin binary dari tahap builder
COPY --from=builder /app/target/release/hbbr /usr/local/bin/hbbr

# Set environment variable yang diperlukan
ENV RUST_BACKTRACE=1

# Tentukan port aplikasi
EXPOSE 21115

# Jalankan aplikasi
CMD ["hbbr"]
