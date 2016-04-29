FROM anapsix/alpine-java:jdk8

ENV KMANAGER_CONF_FILE="conf/application.conf" \
    KMANAGER_VERSION="master" 

RUN adduser -h / -H -D kafka

RUN apk --no-cache add curl tar wget && \
    mkdir -p ${KAFKA_DIR}/log /opt && \
    wget -q -O - https://github.com/yahoo/kafka-manager/archive/${KMANAGER_VERSION}.tar.gz | tar -xzf - -C /opt && \
    mv /opt/kafka-manager-* /opt/kafka-manager && \
    cd /opt/kafka-manager/ && \
    echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt && \
    ./sbt clean dist && \
    unzip -d /opt/ ./target/universal/kafka-manager-*.zip && \
    cd /opt/ && \
    rm -rf /opt/kafka-manager && \
    mv /opt/kafka-manager-* /opt/kafka-manager && \
    rm -rf /tmp/* /root/.sbt /root/.ivy2 && \
    printf '#!/bin/bash -xe\n/opt/kafka-manager/bin/kafka-manager -Dconfig.file=${KMANAGER_CONF_FILE} "${KMANAGER_ARGS}" "${@}"\n' > /opt/kafka-manager/km.sh && \
    mkdir /opt/kafka-manager/jks && \
    chmod +x /opt/kafka-manager/km.sh && \
    chown -R  kafka:kafka /opt/kafka-manager

WORKDIR /opt/kafka-manager

VOLUME ["/opt/kafka-manager/jks"]

EXPOSE 9000
ENTRYPOINT ["./km.sh"]
