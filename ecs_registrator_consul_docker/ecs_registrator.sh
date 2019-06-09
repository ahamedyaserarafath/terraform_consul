#!/bin/bash
CONSUL_IP="54.254.252.6"
export CONSUL_IP
echo "Running: registrator -ip ${CONSUL_IP} $* consul://$CONSUL_IP:8500" > /dev/stderr
registrator -ip "${CONSUL_IP}" "$@" "consul://${CONSUL_IP}:8500"
