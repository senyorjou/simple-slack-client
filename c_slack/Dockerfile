FROM scratch

COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

WORKDIR /app

COPY ./build/linux/x86_64/release/slack_client .

ENTRYPOINT ["/app/slack_client"]
