#!/bin/bash
redisImage="redis:5"
mongoImage="mongo:4-xenial"

originalRedisPort="6379"
originalMongoPort="27017"

redisPort="6380"
mongoPort="27018"

redisContainerName="redis"
mongoContainerName="mongo"

appName="app-docker-network"
appTag="1.0"
appImage="$appName:$appTag"
appContainerName="app-docker-network-container"
appPort="9090"

dockerNetworkName="golang_network"

echo "Getting Required Golang Dependencies..."
dep ensure -v

echo "Building Golang App..."
go build main.go

echo "Pulling required image...."
sudo docker pull $redisImage
sudo docker pull $mongoImage

echo "Removing and building application image"
sudo docker image rm $appImage
sudo docker build --tag $appName:$appTag .

sudo docker-compose up
