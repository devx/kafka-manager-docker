FROM anapsix/alpine-java:jdk8

ENV KMANAGER__CONF_FILE="conf/application.conf" \
    KMANAGER_VERSION="1.3.0.8" \
    KMANAGER_ARGS="1.3.0.8"

RUN adduser -h / -H -D kafka

RUN apk --no-cache add curl tar wget && \
    mkdir -p ${KAFKA_DIR}/log /opt && \
    wget -q -O - https://github.com/yahoo/kafka-manager/archive/${KMANAGER_VERSION}.tar.gz | tar -xzf - -C /opt && \
    mv /opt/kafka-manager-* /opt/kafka-manager && \
    cd /opt/kafka-manager/ && \
    echo 'scalacOptions ++= Seq("-Xmax-classfile-name", "200")' >> build.sbt && \
    ./sbt clean dist && \
    unzip -d /opt/ ./target/universal/kafka-manager-${KMANAGER_VERSION}.zip && \
    cd /opt/ && \
    rm -rf /opt/kafka-manager && \
    mv /opt/kafka-manager-* /opt/kafka-manager && \
    rm -rf /tmp/* /root/.sbt /root/.ivy2 && \
    printf '#!/bin/sh\nexec /opt/kafka-manager/bin/kafka-manager -Dconfig.file=${KM_CONFIGFILE} "${KM_ARGS}" "${@}"\n' > /opt/kafka-manager/km.sh && \
    chmod +x /opt/kafka-manager/km.sh && \
    chown -R  kafka:kafka /opt/kafka-manager

WORKDIR /opt/kafka-manager

RUN mkdir /opt/kafka-manager/jks

VOLUME ["/opt/kafka-manager/jks"]

EXPOSE 9000
ENTRYPOINT ["./km.sh"]
