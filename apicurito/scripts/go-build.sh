#!/bin/bash
REGISTRY=quay.io/${USER}
IMAGE=apicurito-operator
TAG=$(grep Version version/version.go | head -1|awk -F '=' '{print $2}'|sed 's/\ *"//g')
if [[ -z ${TAG} ]]; then
  echo "ERROR: No Version found in version/version.go. "$(grep Version version/version.go|head -1) 
  exit 1
fi

export GO111MODULE=on

go mod vendor

go generate ./...
if [[ -z ${CI} ]]; then
    ./scripts/go-test.sh
    operator-sdk build ${REGISTRY}/${IMAGE}:${TAG}
   
else
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -v -a -o build/_output/bin/apicurito -mod=vendor github.com/apicurio/apicurio-operators/apicurito/cmd/manager

fi