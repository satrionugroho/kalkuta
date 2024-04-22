#/bin/sh

type docker >/dev/null 2>&1 || { echo >&2 "please install docker first"; exit 1; }

ver=${VERSION:-1.0.0}

docker build -t kalkuta/vienna:$ver ../vienna/.
docker build -t kalkuta/berlin:$ver ../berlin/.
docker build -t kalkuta/bordeux:$ver ../bordeux/.
