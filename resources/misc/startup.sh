#!/bin/bash

# Startup daemontools

/usr/bin/svscanboot &

# Wait till Redis starts up
while ! nc -z localhost 6379; do sleep 1; done

echo "SET panoptes:secrets:snmp_community_string:$SNMP_SITE $SNMP_COMM_STRING" | /usr/bin/redis-cli

wait
