# Berlin

Berlin is application to manage user with simple method. Just `simple` user management do not expect anything


## Certificate

To generate the certificate just follow these command
1. Create private key using openssl
```bash
openssl genrsa -out privateKey.pem 2048
```

2. By using privateKey.pem to create public key (optional)
```bash
openssl rsa -in privateKey.pem -pubout -out publicKey.pem
```

## Build

Before you build this application, generate the certificate first by following the instructions in [Certificate](#certificate) section. To build this application you can choose with docker or without docker

### Without  docker
To build without docker just follow this step.

1. Run `mix local.hex --force` to initate the hex folder
2. Run `mix local.rebar --force` to initate the rebar folder
3. Run `MIX_ENV=prod mix deps.get` to get production dependencies
4. Run `mix compile` to compile all the dependencies
5. Run `mix release --force --overwrite` to build and remove previous build


### Docker

To build using docker just simply using command

```bash
docker build -t berlin/v1.0.0 .
```

or build using docker-compose

```bash
docker-compose up -d
```

## Develop
To develop this application by cloning and running build step to ensure the cloned code is perform well. And to develop you must add the test case in `test` folder. And you can run the application by using normal phoenix command

