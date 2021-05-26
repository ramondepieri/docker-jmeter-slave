#!/bin/bash

JMETER_VERSION=${JMETER_VERSION:-"5.4"}
IMAGE_TIMEZONE=${IMAGE_TIMEZONE:-"America/Sao_Paulo"}

# Example build line
docker build  --build-arg JMETER_VERSION=${JMETER_VERSION} --build-arg TZ=${IMAGE_TIMEZONE} -t "ramondepieri/jmeter:${JMETER_VERSION}" .