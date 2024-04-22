# builder image
FROM elixir:1.16.1-otp-26-alpine as builder

# Create new fresh directory
RUN mkdir -p /app \
  && apk update \
  && apk add --no-cache -f cmake make gcc zstd libc-dev

# Copy application files
COPY config /app/config
COPY lib /app/lib
COPY priv /app/priv
COPY test /app/test
COPY rel /app/rel
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

COPY --from=builder /app/_build/prod/rel/bakeware/vienna /app/vienna

# create runtime application
RUN mkdir -p /var/bakeware \
  && chown -R 1001:0 /var/bakeware \
  && chmod -R g=u /var/bakeware

# must run as non-root user
USER 1001

CMD ["/app/vienna"]
