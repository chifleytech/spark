# spark

A `debian:stretclch` based [Spark](http://spark.apache.org) container. Use it in a standalone cluster with the accompanying `docker-compose.yml`, or as a base for more complex recipes.

## docker example

To run `SparkPi`, run the image with Docker:

    docker run --rm -it -p 4040:4040 gettyimages/spark bin/run-example SparkPi 10

To start `spark-shell` with your AWS credentials:

    docker run --rm -it -e "AWS_ACCESS_KEY_ID=YOURKEY" -e "AWS_SECRET_ACCESS_KEY=YOURSECRET" -p 4040:4040 gettyimages/spark bin/spark-shell

To do a thing with Pyspark

    echo -e "import pyspark\n\nprint(pyspark.SparkContext().parallelize(range(0, 10)).count())" > count.py
    docker run --rm -it -p 4040:4040 -v $(pwd)/count.py:/count.py gettyimages/spark bin/spark-submit /count.py

## docker-compose example

To create a simplistic standalone cluster with [docker-compose](http://docs.docker.com/compose):

    docker-compose up

The SparkUI will be running at `http://${YOUR_DOCKER_HOST}:8080` with one worker listed. To run `pyspark`, exec into a container:

    docker exec -it dockerspark_master_1 /bin/bash
    bin/pyspark

To run `SparkPi`, exec into a container:

    docker exec -it dockerspark_master_1 /bin/bash
    bin/run-example SparkPi 10

## license

MIT


## Compose
cd /Users/michaelwalker/spark-2.4.3-bin-hadoop2.7/bin
./beeline -u jdbc:hive2://master.sqlcd:10000 
SELECT unix_timestamp();
CREATE TABLE CUSTOMERS ( ID INT, NAME VARCHAR (20), AGE BIGINT, ADDRESS CHAR (25), SALARY DECIMAL (18, 2)) STORED AS TEXTFILE LOCATION 'hdfs://master.sqlcd:9000/customers';
INSERT INTO CUSTOMERS VALUES (3, 'kaushik', 15, 'Kota', 2000.00 );
CREATE TABLE AGE STORED AS TEXTFILE LOCATION 'hdfs://master.sqlcd:9000/customers_2' AS SELECT AGE *2 FROM CUSTOMERS;
SELECT * FROM AGE ;
 



docker build . -t chifleytech/spark1
docker-compose --file master.yml up 
docker-compose --file worker.yml up 
