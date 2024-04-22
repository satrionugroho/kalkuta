FROM golang:1.22-alpine as build

COPY . .

RUN GOPATH= go build -o /bin/bordeux cmd/main.go

FROM gcr.io/distroless/static-debian11

COPY --from=build /bin/bordeux /bin/bordeux

EXPOSE 3000

ENTRYPOINT ["./bin/bordeux"]
