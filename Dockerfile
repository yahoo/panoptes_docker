# Copyright 2019, Oath Inc.
# Licensed under the terms of the Apache 2.0 license. See LICENSE file in https://github.com/yahoo/panoptes_docker/LICENSE for terms.

FROM ubuntu:18.04
MAINTAINER James Diss <rexfury@verizonmedia.com>
# Update the date to bust cached layers.
ENV Panoptes_environment_refreshed 2020-01-23-12:37
ARG DEBIAN_FRONTEND=noninteractive
# 2181 is zookeeper, 6379 is redis, 9092 is kafka, 161 is snmp, 3000 is grafana, 8086 is influxdb
EXPOSE 80 161/udp 160 2181 3000 6379 8086 9092

# runtime overrideables
ENV SNMP_SITE local
ENV SNMP_COMM_STRING public

# Grafana from the repo.  Minimal apt-get action just in case it moves to repo.
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y curl gnupg && \
    curl https://packages.grafana.com/gpg.key | cat | apt-key add - && \
    echo "deb https://packages.grafana.com/oss/deb stable main" >> /etc/apt/sources.list.d/grafana.list

# Build the rest of the dependencies.
RUN apt-get update && apt-get install -y \
    daemontools-run \
    netcat \
    openjdk-8-jdk \
    nano \
    python3.6 \
    python3-pip \
    python3-setuptools \
    python3-venv \
    python3-influxdb \
    influxdb \
    influxdb-client \
    grafana \
    redis-server \
    snmp \
    snmpd \
    tar \
    zookeeper && \
    apt-get autoremove -y && \
    apt-get clean && \
    update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Support ----
# Kafka - http://kafka.apache.org/downloads
# Installing Kafka ----- /home/kafka - archive.apache.org/dist/kafka/1.1.0/kafka_2.11-1.1.0.tgz
# Building path structures for supporting services
# Adding in various configurations
# changing out the permissions.
RUN mkdir -p /home/downloads && \
    mkdir -p /home/kafka && \
    curl "https://archive.apache.org/dist/kafka/1.1.0/kafka_2.11-1.1.0.tgz" -o /home/downloads/kafka.tgz && \
    cd /home/kafka && \
    tar -xvzf "/home/downloads/kafka.tgz" --strip 1 && \
    mkdir -p /home/kafka/logs && \
    mkdir -p /home/logs/kafka && \
    mkdir -p /home/logs/zookeeper && \
    mkdir -p /home/logs/snmpd && \
    mkdir -p /home/logs/influxdb && \
    mkdir -p /home/logs/grafana && \
    mkdir -p /etc/grafana/provisioning/datasources && \
    mkdir -p /etc/grafana/provisioning/dashboards && \
    mkdir -p /var/lib/grafana/plugins && \
    mkdir -p /var/lib/grafana/dashboards && \
    mkdir -p /home/panoptes/logs/discovery_plugin_agent && \
    mkdir -p /home/panoptes/logs/polling_plugin_scheduler && \
    mkdir -p /home/panoptes/logs/polling_plugin_agent && \
    mkdir -p /home/panoptes/logs/influxdb_consumer && \
    mkdir -p /home/panoptes/logs/enrichment_plugin_scheduler && \
    mkdir -p /home/panoptes/logs/enrichment_plugin_agent && \
    mkdir -p /home/panoptes/logs/discovery_plugin_scheduler && \
    mkdir -p /home/panoptes/logs/discovery_plugin_agent && \
    rm -Rf /home/downloads && \
    cp /home/kafka/config/server.properties /home/kafka/config/server.properties.installed && \
    cp /etc/snmp/snmpd.conf                 /etc/snmp/snmpd.conf.installed && \
    cp /usr/share/grafana/conf/sample.ini   /etc/grafana/grafana.ini && \
    cp /usr/share/grafana/conf/ldap.toml    /etc/grafana/ldap.toml && \
    chown -R grafana:grafana "/var/lib/grafana" "/home/logs/grafana" "/var/lib/grafana/plugins" "/var/lib/grafana/dashboards" && \
    chmod 777 "/var/lib/grafana" "/home/logs/grafana" "/var/lib/grafana/plugins" "/var/lib/grafana/dashboards"

# Copying over the configuration files.
COPY resources/kafka/server.properties  /home/kafka/config/server.properties
COPY resources/snmpd/snmpd.conf         /etc/snmp/snmpd.conf
COPY resources/zookeeper/*              /etc/zookeeper/conf/
# Altering the permissions.
RUN chown nobody:nogroup -R /home/kafka && \
    chown nobody:nogroup -R /home/logs/kafka && \
    chown zookeeper -R /home/logs/zookeeper

# provisioning Grafana - influxDB datasource and default dashboard for localhost.
COPY resources/grafana/datasource.yml          /etc/grafana/provisioning/datasources/datasource.yml
COPY resources/grafana/dashboards.yml          /etc/grafana/provisioning/dashboards/sample.yml
COPY resources/grafana/dashboard.json          /var/lib/grafana/dashboards/localhost.json

# Building out Redis -----
# THP warnings come from the HOST, not the docker image.  Don't go chasing waterfalls.
# docker command -> `--sysctl net.core.somaxconn=511`
COPY resources/redis/redis.conf                 /etc/redis/redis.conf

# Building out daemontools -----
WORKDIR /etc/service/
COPY resources/daemontools/panoptes_discovery_plugin_scheduler.run      ./panoptes_discovery_plugin_scheduler/run
COPY resources/daemontools/panoptes_discovery_plugin_scheduler.runlog   ./panoptes_discovery_plugin_scheduler/log/run
COPY resources/daemontools/panoptes_discovery_plugin_agent.run          ./panoptes_discovery_plugin_agent/run
COPY resources/daemontools/panoptes_discovery_plugin_agent.runlog       ./panoptes_discovery_plugin_agent/log/run
COPY resources/daemontools/panoptes_polling_plugin_scheduler.run        ./panoptes_polling_plugin_scheduler/run
COPY resources/daemontools/panoptes_polling_plugin_scheduler.runlog     ./panoptes_polling_plugin_scheduler/log/run
COPY resources/daemontools/panoptes_polling_plugin_agent.run            ./panoptes_polling_plugin_agent_001/run
COPY resources/daemontools/panoptes_polling_plugin_agent.runlog         ./panoptes_polling_plugin_agent_001/log/run
COPY resources/daemontools/panoptes_enrichment_plugin_scheduler.run     ./panoptes_enrichment_plugin_scheduler/run
COPY resources/daemontools/panoptes_enrichment_plugin_scheduler.runlog  ./panoptes_enrichment_plugin_scheduler/log/run
COPY resources/daemontools/panoptes_enrichment_plugin_agent.run         ./panoptes_enrichment_plugin_agent/run
COPY resources/daemontools/panoptes_enrichment_plugin_agent.runlog      ./panoptes_enrichment_plugin_agent/log/run

COPY resources/daemontools/panoptes_influxdb_consumer.run               ./panoptes_influxdb_consumer/run
COPY resources/daemontools/panoptes_influxdb_consumer.runlog            ./panoptes_influxdb_consumer/log/run

COPY resources/daemontools/panoptes_resource_manager.run                ./panoptes_resource_manager/run
COPY resources/daemontools/panoptes_resource_manager.runlog             ./panoptes_resource_manager/log/run

COPY resources/daemontools/redis-server.run                             ./redis/run
COPY resources/daemontools/redis-server.runlog                          ./redis/log/run
COPY resources/daemontools/zookeeper.run                                ./zookeeper/run
COPY resources/daemontools/zookeeper.runlog                             ./zookeeper/log/run
COPY resources/daemontools/kafka.run                                    ./kafka/run
COPY resources/daemontools/kafka.runlog                                 ./kafka/log/run
COPY resources/daemontools/snmpd.run                                    ./snmpd/run
COPY resources/daemontools/snmpd.runlog                                 ./snmpd/log/run
COPY resources/daemontools/influxdb.run                                 ./influxdb/run
COPY resources/daemontools/influxdb.runlog                              ./influxdb/log/run
COPY resources/daemontools/grafana.run                                  ./grafana/run
COPY resources/daemontools/grafana.runlog                               ./grafana/log/run

# PANOPTES ----
# Installing Panoptes Log/Conf Structure - see resources/logging.ini
RUN adduser --disabled-password --gecos '' panoptes && \
    mkdir -p /home/panoptes/run && \
    mkdir -p /home/panoptes/logs && \
    mkdir -p /home/panoptes/conf && \
    chown panoptes:panoptes -R /home/panoptes

# Copying over the default configurations for Panoptes
# built from https://github.com/yahoo/panoptes/tree/master/examples
COPY resources/panoptes/localhost.json              /home/panoptes/conf/
COPY resources/panoptes/conf/panoptes.ini           /home/panoptes/conf/
COPY resources/panoptes/conf/logging.ini            /home/panoptes/conf/
COPY resources/panoptes/conf/influxdb_consumer.ini  /home/panoptes/conf/
RUN chown panoptes:panoptes /home/panoptes/conf*

# Copying over the plugins
# these are from https://github.com/yahoo/panoptes/tree/master/examples/plugins
COPY resources/panoptes/plugins/discovery/*.panoptes-plugin \
        /home/panoptes_v/lib/python3.6/site-packages/yahoo_panoptes/plugins/discovery/
COPY resources/panoptes/plugins/enrichment/*.panoptes-plugin \
        /home/panoptes_v/lib/python3.6/site-packages/yahoo_panoptes/plugins/enrichment/
COPY resources/panoptes/plugins/polling/*.panoptes-plugin \
        /home/panoptes_v/lib/python3.6/site-packages/yahoo_panoptes/plugins/polling/

# Helper scripts to expose various bits of the supporting services.
COPY resources/misc/*.sh        /home/panoptes/

# Build Panoptes - /home/panoptes_v/bin/python
RUN python3 -m venv /home/panoptes_v && . /home/panoptes_v/bin/activate && pip3 install wheel && pip3 install yahoo-panoptes && deactivate

# cwd /home
WORKDIR /home/panoptes

# Kick off daemontools -----
ENTRYPOINT ["/usr/bin/svscanboot"]
