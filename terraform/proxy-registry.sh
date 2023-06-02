#!/bin/bash
set -e

start_proxy_registry() {
    docker run -d -p 5000:5000 \
    -e REGISTRY_PROXY_REMOTEURL=https://registry-1.docker.io \
    --restart always \
    --name registry-docker.io registry:2

    docker run -d -p 5001:5000 \
    -e REGISTRY_PROXY_REMOTEURL=https://registry.k8s.io \
    --restart always \
    --name registry-registry.k8s.io registry:2

    docker run -d -p 5003:5000 \
    -e REGISTRY_PROXY_REMOTEURL=https://gcr.io \
    --restart always \
    --name registry-gcr.io registry:2

    docker run -d -p 5004:5000 \
    -e REGISTRY_PROXY_REMOTEURL=https://ghcr.io \
    --restart always \
    --name registry-ghcr.io registry:2

    docker run -d -p 5005:5000 \
    -e REGISTRY_PROXY_REMOTEURL=https://quay.io \
    --restart always \
    --name registry-quay.io registry:2

}

stop_proxy_registry() {
    
    docker stop registry-docker.io registry-registry.k8s.io registry-gcr.io registry-ghcr.io registry-quay.io
}

remove_proxy_registry() {

    docker rm registry-docker.io registry-registry.k8s.io registry-gcr.io registry-ghcr.io registry-quay.io
}


# Check command line argument exist
if [ "$1" == "" ] || [ $# -gt 1 ]; then
    echo "Error: Command line argument is missing. Must be start, stop or remove"
    exit 1
fi

verb="$1"
case "$verb" in
    "start" ) 
      start_proxy_registry
      ;;
    "stop" ) 
      stop_proxy_registry
      ;;
    "remove" ) 
      remove_proxy_registry
      ;;
    *)
    echo "Wrong argument. Must be start, stop or remove"
    exit 1
    ;;
esac


