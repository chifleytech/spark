#!/usr/bin/env bash
/root/copy-udfs.sh
bin/spark-class org.apache.spark.deploy.worker.Worker $MASTER