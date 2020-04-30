FROM golang:1.11.4

COPY main /app/main

ENV NAME=Adrian
ENV APP_PORT=9090

ENV REDIS_HOST=redis

# Guess what, we connect to original port
ENV REDIS_PORT=6379

ENV MONGO_HOST=mongo
ENV MONGO_PORT=27017

CMD ["/app/main"]

