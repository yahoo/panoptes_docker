#!/bin/sh
# Copyright 2019, Oath Inc.
#
# Licensed under the terms of the Apache 2.0 license. See LICENSE file in https://github.com/yahoo/panoptes_docker/LICENSE for terms.

echo "--Databases--------\n"
/usr/bin/influx -database 'Panoptes' -format=csv -execute 'SHOW DATABASES'
echo "--Measurements-----\n"
/usr/bin/influx -database 'Panoptes' -format=csv -execute 'SHOW MEASUREMENTS'

echo "--interface-----\n"
curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=Panoptes" --data-urlencode "q=SELECT * FROM interface"
echo "--stats---------\n"
curl -G 'http://localhost:8086/query?pretty=true' --data-urlencode "db=Panoptes" --data-urlencode "q=SELECT * FROM status"

tail -f /home/logs/influxdb/current /home/panoptes/logs/influxdb_consumer/current
