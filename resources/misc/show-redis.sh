#!/bin/sh
# Copyright 2019, Oath Inc.
#
# Licensed under the terms of the Apache 2.0 license. See LICENSE file in https://github.com/yahoo/panoptes_docker/LICENSE for terms.

echo "--Keys-------\n"
redis-cli --scan --pattern '*'

echo "--Stats------\n"
redis-cli --stat
