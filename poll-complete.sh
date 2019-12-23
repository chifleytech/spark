printf "Waiting for Spark to initialize..."
while [ ! -f /tmp/data/restore_complete ]
do
  sleep 3
  printf "."
done
echo ""
echo "##############"
echo "Spark Ready"
echo "Cluster http://localhost:8084"
echo "Thrift application http://localhost:8085"
echo "History http://localhost:8086"
echo "HDFS browser http://localhost:8087"
echo "Worker http://localhost:8088"
echo "Thrift JDBC jdbc:hive2://localhost:5434"
echo "##############"