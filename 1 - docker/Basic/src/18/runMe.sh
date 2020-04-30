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

echo "Stoping existing container...."
sudo docker container stop $redisContainerName
sudo docker container stop $mongoContainerName
sudo docker container stop $appContainerName

echo "Removing existing container...."
sudo docker container rm $redisContainerName
sudo docker container rm $mongoContainerName
sudo docker container rm $appContainerName

echo "Removing and building application image"
sudo docker image rm $appImage
sudo docker build --tag $appName:$appTag .

echo "Creating container...."
sudo docker container create --name $redisContainerName -p $redisPort:$originalRedisPort $redisImage
sudo docker container create --name $mongoContainerName -p $mongoPort:$originalMongoPort $mongoImage
sudo docker container create --name $appContainerName -p $appPort:$appPort $appImage

echo "Starting container"
sudo docker container start $redisContainerName
sudo docker container start $mongoContainerName
sudo docker container start $appContainerName

echo "Creating and setting network...."
sudo docker network rm $dockerNetworkName
sudo docker network create $dockerNetworkName
sudo docker network connect $dockerNetworkName $redisContainerName
sudo docker network connect $dockerNetworkName $mongoContainerName
sudo docker network connect $dockerNetworkName $appContainerName

echo "Showing running container..."
sudo docker container ls
sudo docker logs -f $appContainerName
