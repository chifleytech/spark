#!/usr/bin/env bash
cd $SPARK_HOME
./sbin/start-master.sh
./sbin/start-history-server.sh
date

/etc/init.d/ssh start

cd $HADOOP_HOME
if [ -z "$(ls -A /tmp/hadoop-root/dfs/name)" ]; then
   bin/hdfs namenode -format
else
   echo "Not Empty"
fi
./sbin/start-dfs.sh

while bin/hdfs dfsadmin -safemode wait | grep ON
do
    sleep 1s # Or 10s or 1m or whatever time
done

cd $SPARK_HOME
./sbin/start-thriftserver.sh

if [ "$(ls -A /root/upload-data)" ]; then
   echo "uploading data...."
   hdfs dfs -mkdir /data/
   hdfs dfs -mkdir /experiments/
   cd /root/upload-data
   for f in *.sh; do
        echo "$f"
        bash "$f" -H
   done
fi

if [ -f /root/create_tables.sql ]; then
    echo "creating tables"
    beeline -u jdbc:hive2://master:10000 -f /root/create_tables.sql
fi

date
trap : TERM INT
tail -f /dev/null & wait