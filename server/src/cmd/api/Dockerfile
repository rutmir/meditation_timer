FROM rust:1.87-alpine AS builder

RUN apk update
# build-base: gcc/g++/make needed by solana-sdk transitive C deps (ring, libsecp256k1 etc.)
# perl: required by ring's asm preprocessing
# musl-dev: musl libc headers for static linking
# libressl-dev: TLS headers (reqwest rustls-tls doesn't need it, kept for safety)
RUN apk add --no-cache musl-dev libressl-dev build-base perl

# Install musl target for static linking
RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/app

# Copy Cargo.toml and Cargo.lock first to leverage Docker caching for dependencies
COPY Cargo.toml Cargo.lock ./

# Build dummy to cache dependencies (api feature only — avoids gemini-rs from job feature)
RUN mkdir src && echo "fn main() {}" > src/main.rs && cargo build --target x86_64-unknown-linux-musl --release --no-default-features --features api

# Remove dummy file and copy actual source code
RUN rm src/main.rs

# Copy source code and build the application
COPY ./src ./src
RUN cargo build --manifest-path ./src/cmd/api/Cargo.toml --target x86_64-unknown-linux-musl --release

FROM alpine:latest

#RUN apk update \
#    && apk add openssl ca-certificates

# Create a non-root user for security
RUN adduser -D appuser
USER appuser

WORKDIR /app

# Copy the compiled binary from the builder stage
COPY --from=builder /usr/src/app/src/cmd/api/target/x86_64-unknown-linux-musl/release/meditimer-api ./meditimer-api

# Copy default config — override solana.roex_mint and redis via mounted volume or ENV vars.
# Note: figment split("_") cannot set underscore-named fields (e.g. rpc_url, roex_mint) via
# APP_SOLANA_* env vars; mount a custom app_config.toml for those overrides.
COPY --from=builder /usr/src/app/src/cmd/api/app_config.toml ./app_config.toml

# Expose port if your application is a server
EXPOSE 3000

## Run the application
#CMD ["/usr/local/bin/meditimer-api"]

# Define the command to run your application
CMD ["./meditimer-api"]