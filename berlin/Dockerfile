# builder image
FROM elixir:1.16.1-otp-26-alpine as builder

# Create new fresh directory
RUN mkdir -p /app \
  && apk update \
  && apk add --no-cache -f libsodium-dev yaml-dev ca-certificates git cmake make gcc zstd libc-dev

# Copy application files
COPY config /app/config
COPY lib /app/lib
COPY priv /app/priv
COPY test /app/test
COPY config.yml /app/config.yml
COPY mix.exs /app/mix.exs
COPY mix.lock /app/mix.lock

# move the workdir to /app
WORKDIR /app

# must build on production env
ENV MIX_ENV=prod

# installing hex
RUN mix local.hex --force \
  && mix local.rebar --force \
  && mix deps.get \
  && mix do compile \
  && mix release --force --overwrite

# build runtime image
FROM alpine:3.19

# copy necessary files
COPY --from=builder /app/_build/prod/rel/bakeware/berlin /app/berlin
COPY --from=builder /usr/lib/libyaml-0.so.2 /usr/lib/libyaml-0.so.2
COPY --from=builder /usr/lib/libncursesw.so.6 /usr/lib/libncursesw.so.6
COPY --from=builder /usr/lib/libgcc_s.so.1 /usr/lib/libgcc_s.so.1
COPY --from=builder /usr/lib/libstdc++.so.6 /usr/lib/libstdc++.so.6
COPY --from=builder /usr/lib/libsodium.so* /usr/lib/.

# create runtime application
RUN mkdir -p /var/bakeware \
  && chown -R 1001:0 /var/bakeware \
  && chmod -R g=u /var/bakeware

# must run as non-root user
USER 1001

ENV BAKEWARE_CACHE=/var/bakeware

# Expose only used port
EXPOSE 4000

ENTRYPOINT ["/app/berlin"]
