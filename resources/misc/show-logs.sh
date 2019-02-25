#!/bin/sh
# Copyright 2019, Oath Inc.
#
# Licensed under the terms of the Apache 2.0 license. See LICENSE file in https://github.com/yahoo/panoptes_docker/LICENSE for terms.

tail -f /home/logs/kafka/current \
        /home/logs/zookeeper/current \
        /home/logs/redis/current \
        /home/logs/grafana/current \
        /home/logs/influxdb/current \
        /home/kafka/logs/controller.log \
        /home/kafka/logs/server.log \
        /home/kafka/logs/log-cleaner.log
