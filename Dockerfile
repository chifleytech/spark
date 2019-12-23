FROM debian:stretch
MAINTAINER Getty Images "https://github.com/gettyimages"

RUN apt-get update \
 && apt-get install -y locales \
 && dpkg-reconfigure -f noninteractive locales \
 && locale-gen C.UTF-8 \
 && /usr/sbin/update-locale LANG=C.UTF-8 \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Users with other locales should set this in their derivative image
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update \
 && apt-get install -y curl unzip \
    python3 python3-setuptools \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && easy_install3 pip py4j \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0
ENV PYTHONIOENCODING UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK 1

# JAVA
RUN apt-get update \
 && apt-get install -y openjdk-8-jre \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# HADOOP
ENV HADOOP_VERSION 3.2.1
ENV HADOOP_HOME /usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV PATH $PATH:$HADOOP_HOME/bin
# "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
# "http://apache.mirror.cdnetworks.com/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
RUN curl -L --retry 3 \
  "http://apache.mirror.cdnetworks.com/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x -C /usr/ \
 && rm -rf $HADOOP_HOME/share/doc \
 && chown -R root:root $HADOOP_HOME

# SPARK
ENV SPARK_VERSION 2.4.4
ENV SPARK_PACKAGE spark-${SPARK_VERSION}-bin-hadoop2.7
ENV SPARK_HOME /usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*"
ENV PATH $PATH:${SPARK_HOME}/bin
# "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
# "http://apache.mirror.cdnetworks.com/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
RUN curl -L --retry 3 \
  "http://apache.mirror.cdnetworks.com/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
 && mv /usr/$SPARK_PACKAGE $SPARK_HOME \
 && chown -R root:root $SPARK_HOME

RUN apt-get update \
 && apt-get install -y ssh openssh-server
RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN chmod 0600 ~/.ssh/authorized_keys

COPY core-site.xml $HADOOP_CONF_DIR/core-site.xml
COPY hdfs-site.xml $HADOOP_CONF_DIR/hdfs-site.xml
COPY hadoop-env.sh $HADOOP_CONF_DIR/hadoop-env.sh
#ADD spark-defaults.conf /conf/spark-defaults.conf

# add init script
COPY master.sh /root/master.sh
COPY worker.sh /root/worker.sh
COPY copy-udfs.sh /root/copy-udfs.sh
RUN chmod 755 /root/*.sh
ENV PATH $PATH:/root

#todo: Set HDFS permissions https://hadoop.apache.org/docs/r3.0.3/hadoop-project-dist/hadoop-hdfs/HdfsPermissionsGuide.html

#ADD hive-site.xml $SPARK_HOME/conf/hive-site.xml
#ADD core-site.xml $SPARK_HOME/conf/core-site.xml
COPY spark-env.sh $SPARK_HOME/conf/spark-env.sh
COPY poll-complete.sh /poll-complete.sh
RUN chmod 755 /poll-complete.sh
ENV SPARK_DIST_CLASSPATH $SPARK_DIST_CLASSPATH:/udf/*
WORKDIR $SPARK_HOME

RUN mkdir /root/existing-udfs
RUN mkdir /tmp/spark-events
CMD ["bin/spark-class", "org.apache.spark.deploy.master.Master"]

