FROM docker.io/library/rust:1.83 as builder

WORKDIR /usr/src/app
COPY . .

RUN cargo build --release

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y libssl-dev ca-certificates && rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/src/app/target/release/kube-rust-server /usr/local/bin/

EXPOSE 8080

CMD ["kube-rust-server"]
