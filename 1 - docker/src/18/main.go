package main

import (
	"context"
	"fmt"
	"net/http"
	"os"

	"github.com/go-redis/redis"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

func testConnectRedis() {
	redisHost := os.Getenv("REDIS_HOST")
	redisPort := os.Getenv("REDIS_PORT")

	fmt.Println("Trying to connect redis", redisHost, ":", redisPort)

	client := redis.NewClient(&redis.Options{
		Addr:     redisHost + ":" + redisPort,
		Password: "", // no password set
		DB:       0,  // use default DB
	})

	_, err := client.Ping().Result()

	if err != nil {
		panic(err)

	}

	fmt.Println("Successfully Connect Redis...")
}

func testConnectMongo() {
	mongoHost := os.Getenv("MONGO_HOST")
	mongoPort := os.Getenv("MONGO_PORT")
	ctx := context.Background()

	fmt.Println("Trying to connect mongo", mongoHost, ":", mongoPort)

	clientOptions := options.Client()
	clientOptions.ApplyURI("mongodb://" + mongoHost + ":" + mongoPort)

	client, err := mongo.NewClient(clientOptions)

	if err != nil {
		panic(err)
	}

	err = client.Connect(ctx)

	if err != nil {
		panic(err)
	}

	err = client.Ping(context.TODO(), nil)

	if err != nil {
		panic(err)
	}

	fmt.Println("Successfully Connect Mongo...")
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		testConnectRedis()
		testConnectMongo()
		fmt.Println("----------------------------------------------------")
		fmt.Fprintf(w, "Hello World "+os.Getenv("NAME")+"!")
	})

	appPort := os.Getenv("APP_PORT")

	fmt.Println("Starting server on ", appPort)
	err := http.ListenAndServe(":"+appPort, nil)

	panic(err)
}
