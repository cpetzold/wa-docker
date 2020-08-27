Worms Armageddon Docker Image
=============================

This is a Docker image for a headless Worms Armageddon installation, suitable for batch tasks such as replay extraction.

Current W:A version: 3.8

Building
--------

```shell
git clone https://github.com/CyberShadow/wa-docker
cd wa-docker
docker build -t wa .
```

Usage
-----

```shell
docker run --rm -i wa wa-getlog < your-replay.WAgame > your-replay.log
```
