#!/bin/sh
# Copyright 2019, Oath Inc.
#
# Licensed under the terms of the Apache 2.0 license. See LICENSE file in https://github.com/yahoo/panoptes_docker/LICENSE for terms.

svstat /etc/service/redis
svstat /etc/service/kafka
svstat /etc/service/zookeeper
svstat /etc/service/snmpd
svstat /etc/service/influxdb
svstat /etc/service/grafana

svstat /etc/service/panoptes_influxdb_consumer
svstat /etc/service/panoptes_resource_manager

svstat /etc/service/panoptes_discovery_plugin_agent
svstat /etc/service/panoptes_discovery_plugin_scheduler
svstat /etc/service/panoptes_enrichment_plugin_agent
svstat /etc/service/panoptes_enrichment_plugin_scheduler
svstat /etc/service/panoptes_polling_plugin_agent_001
svstat /etc/service/panoptes_polling_plugin_scheduler

