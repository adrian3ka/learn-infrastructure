#!/bin/bash
redisImage="redis:5"
mongoImage="mongo:4-xenial"

originalRedisPort="6379"
originalMongoPort="27017"

redisPort="6380"
mongoPort="27017"

redisContainerName="redis"
mongoContainerName="mongo"

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

echo "Removing existing container...."
sudo docker container rm $redisContainerName
sudo docker container rm $mongoContainerName

echo "Creating container...."
sudo docker container create --name $redisContainerName -p $redisPort:$originalRedisPort $redisImage
sudo docker container create --name $mongoContainerName -p $mongoPort:$originalMongoPort $mongoImage

echo "Starting container"
sudo docker container start $redisContainerName
sudo docker container start $mongoContainerName

echo "Showing running container..."
sudo docker container ls
