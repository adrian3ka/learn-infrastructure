package main

import (
	"fmt"
	"github.com/go-redis/redis"
	"net/http"
	"os"
)

func testConnectRedis() {
	redisHost := os.Getenv("REDIS_HOST")
	redisPort := os.Getenv("REDIS_PORT")

	client := redis.NewClient(&redis.Options{
		Addr:     redisHost + ":" + redisPort,
		Password: "", // no password set
		DB:       0,  // use default DB
	})

	_, err := client.Ping().Result()

	if err == nil {
		fmt.Println("Successfully Connect Redis...")
		return
	}

	fmt.Println(err)
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		testConnectRedis()
		fmt.Fprintf(w, "Hello World "+os.Getenv("NAME")+"!")
	})

	appPort := os.Getenv("APP_PORT")

	err := http.ListenAndServe(":" + appPort, nil)

	panic(err)
}
