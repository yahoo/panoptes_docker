# Panoptes_docker Quickstart Guide

This is a quickstart to get running with a workbench version of Panoptes inside a Docker container that is intended to 
be used for testing concepts and observing code operations.

## Build the image

```
git clone https://github.com/yahoo/panoptes_docker.git && cd panoptes_docker
docker build . -t panoptes_docker
```

## Run the image

Run as a container.  This does use quite a lot of processor as Panoptes is a distributed system jammed into a tiny 
container.

You can run a minimal default container with;

```bash
docker run -d --sysctl net.core.somaxconn=511 --name="panoptes_docker" --shm-size=2G -p 127.0.0.1:8080:3000/tcp \
    panoptes_docker
```

More advanced options are available to change operations of the container. 

The `-v` join effectively overlays the *default* localhost.json built into the container.  This example uses a 
localhost.json at `/data/servers/panoptes/conf` on the host machine. Please substitute your own locations and/or 
filenames, but the destination inside the container should stay the same - `/home/panoptes/conf/localhost.json`.

Both `-e` variables are optional and default during build time to the values shown.

```bash
docker run -d \
    --sysctl net.core.somaxconn=511 \
    --name="panoptes_docker" \
    --shm-size=2G \
    -e SNMP_SITE="localhost" \
    -e SNMP_COMM_STRING="public" \
    -v /data/servers/panoptes/conf/localhost.json:/home/panoptes/conf/localhost.json \
    -p 127.0.0.1:8080:3000/tcp \
    panoptes_docker
```

We had some problems getting the community strings into redis, so you will need to run the script 
`/etc/redis/populate_redis.sh` inside the container.  We'll fix this inconvenience at some point.

```bash
docker exec -it panoptes_docker bash
/etc/redis/populate_redis.sh
exit
```

This will populate redis with the SNMP_SITE and SNMP_COMM_STRING environment variables.

Note:  There is a five minute delay until the first metrics will show up.

Grafana can be reached at http://127.0.0.1:8080 with 'admin' as the username and password; this dashboard will show 
network statistics for localhost.  [More details about the Grafana instance can be found here](Readme.md#grafana).

The container itself consumes around 200Mb of memory an hour.

Gain access to the running container:

```
docker exec -it panoptes_docker bash
```

To use any of the python scripts, you need to enable the virtual environment:

```
source /home/panoptes_v/bin/activate
```

Once you're done, stop and remove the container before trying to run another:

```
docker stop panoptes_docker && docker rm panoptes_docker
```

## Configuration

Panoptes runs as a python module, so the relevant code is under site-packages in the virtual environment 
(`/home/panoptes_v/lib/site-packages`)

### Docker development

Each build produces an image that will be untagged unless you're tagging _everything_.  To clear out the image cruft;

```
docker rmi $(docker images -f "dangling=true" -q)
```

To clear out the container cruft;

```
docker rm $(docker ps -aq)
```
