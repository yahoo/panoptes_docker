Panoptes configuration files
============================

All files from the conf directory have been drawn and modified from
https://github.com/yahoo/panoptes/tree/master/examples/conf

# Building a local Python environment

Useful for IDEs that don't build environments.  Requires that python3 is installed, along with python3-venv.

```bash
python3 -m venv ./panoptes_v && \
source ./panoptes_v/bin/activate && \
pip3 install wheel && \
pip3 install yahoo-panoptes
```

Ignore the warnings about Kombu.

# Mounting directories from the Host to the Container

## localhost.json override

You can override the default [localhost.json](resources/panoptes/localhost.json) by supplying one externally and adding 
a flag during the container runtime. The `-v` join effectively overlays the *default* localhost.json built into the 
container.  This example uses a localhost.json at `/dev/panoptes/conf` on the host.

Use `-v <source_location>:/home/panoptes/conf/localhost.json` as a template.

```bash
docker run -d \
    --sysctl net.core.somaxconn=511 \
    --name="panoptes_docker" \
    --shm-size=2G \
    -v /dev/panoptes/conf/localhost.json:/home/panoptes/conf/localhost.json \
    -p 127.0.0.1:8080:3000/tcp \
    panoptes_docker
```

## Mounting external plugin directories.

The same process can be applied to mount plugin directories from the host to the container.

For example, we want to test our tutorial plugin `/dev/panoptes/plugin/test/tutorial_polling_plugin.py` against the 
running container.  Because it's a polling plugin, we'll want it to be mounted in the path for the polling plugins, or 
`/home/panoptes_v/lib/python3.6/site-packages/yahoo_panoptes/plugins/polling/`.  This makes it available to the python 
venv.

```bash
docker run -d \
    --sysctl net.core.somaxconn=511 \
    --name="panoptes_docker" \
    --shm-size=2G \
    -v /dev/panoptes/plugin/test:/home/panoptes_v/lib/python3.6/site-packages/yahoo_panoptes/plugins/polling/test \
    -p 127.0.0.1:8080:3000/tcp \
    panoptes_docker
```

You can mount multiple volumes to test multiple plugins, or change the device data.  For example, combining the 
localhost.json mount above, we can create a development environment;

```bash
docker run -d \
    --sysctl net.core.somaxconn=511 \
    --name="panoptes_docker" \
    --shm-size=2G \
    -v /dev/panoptes/plugin/test:/home/panoptes_v/lib/python3.6/site-packages/yahoo_panoptes/plugins/polling/test \
    -v /dev/panoptes/conf/localhost.json:/home/panoptes/conf/localhost.json \
    -p 127.0.0.1:8080:3000/tcp \
    panoptes_docker
```
