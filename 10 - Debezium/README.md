This command runs a new container using version 1.2 of the debezium/zookeeper image:
```
docker run -it --rm --name zookeeper -p 2181:2181 -p 2888:2888 -p 3888:3888 debezium/zookeeper:1.2
```

This command runs a new container using version 1.2 of the debezium/kafka image:
```
docker run -it --rm --name kafka -p 9092:9092 --link zookeeper:zookeeper debezium/kafka:1.2
```

At this point, you have started ZooKeeper and Kafka, but you still need a database server from which Debezium can capture changes. In this procedure, you will start a MySQL server with an example database.
```
docker run -it --rm --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=debezium -e MYSQL_USER=mysqluser -e MYSQL_PASSWORD=mysqlpw debezium/example-mysql:1.2
```

Starting a MySQL command line client
After starting MySQL, you start a MySQL command line client so that you access the sample inventory database.
```
docker run -it --rm --name mysqlterm --link mysql --rm mysql:5.7 sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'

use inventory;

show tables;

SELECT * FROM customers;
```

This command runs a new container using the 1.2 version of the debezium/connect image:
```
docker run -it --rm --name connect -p 8083:8083 -e GROUP_ID=1 -e CONFIG_STORAGE_TOPIC=my_connect_configs -e OFFSET_STORAGE_TOPIC=my_connect_offsets -e STATUS_STORAGE_TOPIC=my_connect_statuses --link zookeeper:zookeeper --link kafka:kafka --link mysql:mysql debezium/connect:1.2
```

Open a new terminal and check the status of the Kafka Connect service:
```
curl -H "Accept:application/json" localhost:8083/
```

Check the list of connectors registered with Kafka Connect:
```
curl -H "Accept:application/json" localhost:8083/connectors/
```

Open a new terminal, and use the curl command to register the Debezium MySQL connector:
```
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '{ "name": "inventory-connector", "config": { "connector.class": "io.debezium.connector.mysql.MySqlConnector", "tasks.max": "1", "database.hostname": "mysql", "database.port": "3306", "database.user": "debezium", "database.password": "dbz", "database.server.id": "184054", "database.server.name": "dbserver1", "database.whitelist": "inventory", "database.history.kafka.bootstrap.servers": "kafka:9092", "database.history.kafka.topic": "dbhistory.inventory" } }'
```

Verify that inventory-connector is included in the list of connectors:
```
curl -H "Accept:application/json" localhost:8083/connectors/
```

This command runs the watch-topic utility in a new container using the 1.2 version of the debezium/kafka image:
```
docker run -it --rm --name watcher --link zookeeper:zookeeper --link kafka:kafka debezium/kafka:1.2 watch-topic -a -k dbserver1.inventory.customers
```

In the terminal that is running the MySQL command line client, run the following statement:
```
UPDATE customers SET first_name='Anne Marie' WHERE id=1004;
```

Review the connector’s tasks:
```
curl -X GET -H "Accept:application/json" localhost:8083/connectors/inventory-connector| jq
```

Switch to the terminal running watch-topic to see a new fifth event.
```
  {
    "schema": {
      "type": "struct",
      "name": "dbserver1.inventory.customers.Key"
      "optional": false,
      "fields": [
        {
          "field": "id",
          "type": "int32",
          "optional": false
        }
      ]
    },
    "payload": {
      "id": 1004
    }
  }
```

Here is that new event’s value. There are no changes in the schema section, so only the payload section is shown (formatted for readability):
```
{
  "schema": {...},
  "payload": {
    "before": {  
      "id": 1004,
      "first_name": "Anne",
      "last_name": "Kretchmar",
      "email": "annek@noanswer.org"
    },
    "after": {  
      "id": 1004,
      "first_name": "Anne Marie",
      "last_name": "Kretchmar",
      "email": "annek@noanswer.org"
    },
    "source": {  
      "name": "1.3.0.Alpha1",
      "name": "dbserver1",
      "server_id": 223344,
      "ts_sec": 1486501486,
      "gtid": null,
      "file": "mysql-bin.000003",
      "pos": 364,
      "row": 0,
      "snapshot": null,
      "thread": 3,
      "db": "inventory",
      "table": "customers"
    },
    "op": "u",  
    "ts_ms": 1486501486308  
  }
}
```

In the terminal that is running the MySQL command line client, run the following statement:
DELETE FROM customers WHERE id=1004;

```
DELETE FROM customers WHERE id=1004;
```

If the above command fails with a foreign key constraint violation, then you must remove the reference of the customer address from the addresses table using the following statement:
```
DELETE FROM addresses WHERE customer_id=1004;
```

Open a new terminal and use it to stop the connect container that is running the Kafka Connect service:
```
docker stop connect
```

While the service is down, switch to the terminal for the MySQL command line client, and add a few records:
```
INSERT INTO customers VALUES (default, "Sarah", "Thompson", "kitt@acme.com");
INSERT INTO customers VALUES (default, "Kenneth", "Anderson", "kander@acme.com");
```

Open a new terminal, and use it to restart the Kafka Connect service in a container.

This command starts Kafka Connect using the same options you used when you initially started it:
```
$ docker run -it --rm --name connect -p 8083:8083 -e GROUP_ID=1 -e CONFIG_STORAGE_TOPIC=my_connect_configs -e OFFSET_STORAGE_TOPIC=my_connect_offsets -e STATUS_STORAGE_TOPIC=my_connect_statuses --link zookeeper:zookeeper --link kafka:kafka --link mysql:mysql debezium/connect:1.2
```

Switch to the terminal running watch-topic to see events for the two new records you created when Kafka Connect was offline:
```
{"schema":{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"}],"optional":false,"name":"dbserver1.inventory.customers.Key"},"payload":{"id":1005}}	{"schema":{"type":"struct","fields":[{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":false,"field":"first_name"},{"type":"string","optional":false,"field":"last_name"},{"type":"string","optional":false,"field":"email"}],"optional":true,"name":"dbserver1.inventory.customers.Value","field":"before"},{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":false,"field":"first_name"},{"type":"string","optional":false,"field":"last_name"},{"type":"string","optional":false,"field":"email"}],"optional":true,"name":"dbserver1.inventory.customers.Value","field":"after"},{"type":"struct","fields":[{"type":"string","optional":true,"field":"version"},{"type":"string","optional":false,"field":"name"},{"type":"int64","optional":false,"field":"server_id"},{"type":"int64","optional":false,"field":"ts_sec"},{"type":"string","optional":true,"field":"gtid"},{"type":"string","optional":false,"field":"file"},{"type":"int64","optional":false,"field":"pos"},{"type":"int32","optional":false,"field":"row"},{"type":"boolean","optional":true,"field":"snapshot"},{"type":"int64","optional":true,"field":"thread"},{"type":"string","optional":true,"field":"db"},{"type":"string","optional":true,"field":"table"}],"optional":false,"name":"io.debezium.connector.mysql.Source","field":"source"},{"type":"string","optional":false,"field":"op"},{"type":"int64","optional":true,"field":"ts_ms"}],"optional":false,"name":"dbserver1.inventory.customers.Envelope","version":1},"payload":{"before":null,"after":{"id":1005,"first_name":"Sarah","last_name":"Thompson","email":"kitt@acme.com"},"source":{"version":"1.3.0.Alpha1","name":"dbserver1","server_id":223344,"ts_sec":1490635153,"gtid":null,"file":"mysql-bin.000003","pos":1046,"row":0,"snapshot":null,"thread":3,"db":"inventory","table":"customers"},"op":"c","ts_ms":1490635181455}}
{"schema":{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"}],"optional":false,"name":"dbserver1.inventory.customers.Key"},"payload":{"id":1006}}	{"schema":{"type":"struct","fields":[{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":false,"field":"first_name"},{"type":"string","optional":false,"field":"last_name"},{"type":"string","optional":false,"field":"email"}],"optional":true,"name":"dbserver1.inventory.customers.Value","field":"before"},{"type":"struct","fields":[{"type":"int32","optional":false,"field":"id"},{"type":"string","optional":false,"field":"first_name"},{"type":"string","optional":false,"field":"last_name"},{"type":"string","optional":false,"field":"email"}],"optional":true,"name":"dbserver1.inventory.customers.Value","field":"after"},{"type":"struct","fields":[{"type":"string","optional":true,"field":"version"},{"type":"string","optional":false,"field":"name"},{"type":"int64","optional":false,"field":"server_id"},{"type":"int64","optional":false,"field":"ts_sec"},{"type":"string","optional":true,"field":"gtid"},{"type":"string","optional":false,"field":"file"},{"type":"int64","optional":false,"field":"pos"},{"type":"int32","optional":false,"field":"row"},{"type":"boolean","optional":true,"field":"snapshot"},{"type":"int64","optional":true,"field":"thread"},{"type":"string","optional":true,"field":"db"},{"type":"string","optional":true,"field":"table"}],"optional":false,"name":"io.debezium.connector.mysql.Source","field":"source"},{"type":"string","optional":false,"field":"op"},{"type":"int64","optional":true,"field":"ts_ms"}],"optional":false,"name":"dbserver1.inventory.customers.Envelope","version":1},"payload":{"before":null,"after":{"id":1006,"first_name":"Kenneth","last_name":"Anderson","email":"kander@acme.com"},"source":{"version":"1.3.0.Alpha1","name":"dbserver1","server_id":223344,"ts_sec":1490635160,"gtid":null,"file":"mysql-bin.000003","pos":1356,"row":0,"snapshot":null,"thread":3,"db":"inventory","table":"customers"},"op":"c","ts_ms":1490635181456}}
```

After you are finished with the tutorial, you can use Docker to stop all of the running containers:
```
docker stop mysqlterm watcher connect mysql kafka zookeeper
```

source: https://debezium.io/documentation/reference/tutorial.html#starting-zookeeper
