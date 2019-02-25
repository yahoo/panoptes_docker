#!/bin/sh
# Copyright 2019, Oath Inc.
#
# Licensed under the terms of the Apache 2.0 license. See LICENSE file in https://github.com/yahoo/panoptes_docker/LICENSE for terms.

# 'R U OK?'
echo ruok | nc localhost 2181
# 'Serving environment'
echo envi | nc localhost 2181
# 'Outstanding Requests'
echo reqs | nc localhost 2181
# 'Stats'
echo stats | nc localhost 2181
