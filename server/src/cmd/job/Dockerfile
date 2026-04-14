FROM rust:1.87-alpine AS builder

RUN apk update
#RUN apk add --no-cache libc-dev openssl-dev build-base musl-dev pkgconfig 
#RUN apk add --no-cache libc-dev libressl-dev build-base musl-dev pkgconfig
RUN apk add --no-cache musl-dev libressl-dev

# Install musl target for static linking
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/app

# Copy Cargo.toml and Cargo.lock first to leverage Docker caching for dependencies
COPY Cargo.toml Cargo.lock ./

# Build dummy to cache dependencies (job feature only — avoids solana-sdk from api feature)
RUN mkdir src && echo "fn main() {}" > src/main.rs && cargo build --target x86_64-unknown-linux-musl --release --no-default-features --features job

# Remove dummy file and copy actual source code
RUN rm src/main.rs

# Copy source code and build the application
COPY ./src ./src
RUN cargo build --manifest-path ./src/cmd/job/Cargo.toml --target x86_64-unknown-linux-musl --release

FROM alpine:latest

#RUN apk update \
#    && apk add openssl ca-certificates

# Create a non-root user for security
RUN adduser -D appuser
USER appuser

WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/app/src/cmd/job/target/x86_64-unknown-linux-musl/release/meditimer-job ./meditimer-job

# Expose port if your application is a server
# EXPOSE 8000

## Run the application
#CMD ["/usr/local/bin/meditimer-job"]

# Define the command to run your application
CMD ["./meditimer-job"]