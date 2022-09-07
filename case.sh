#!/bin/bash

hostname=`hostname`
RABBITMQ_NODENAME=${RABBITMQ_NODENAME:-rabbit}

if [ -z "$CLUSTER_WITH" -o "$CLUSTER_WITH" = "$hostname" ]; then
  echo "Running as single server"
  rabbitmq-server
else
  echo "Running as clustered server"
  /usr/sbin/rabbitmq-server -detached
  rabbitmqctl stop_app

  echo "Joining cluster $CLUSTER_WITH"
  rabbitmqctl join_cluster ${ENABLE_RAM:+--ram} $RABBITMQ_NODENAME@$CLUSTER_WITH

  rabbitmqctl start_app

  # Tail to keep the a foreground process active..
  tail -f /var/log/rabbitmq/*
fi