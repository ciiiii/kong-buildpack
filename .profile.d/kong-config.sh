#!/usr/bin/env bash

echo "Configuring Kong (.profile.d/kong-config.sh)"

SRC_DIR=/app
BIN_DIR=$(
    cd "$(dirname "$0")"
    pwd
)
export KONG_CLUSTER_PRIVATE_IP=$(ip -4 -o addr show dev eth1)
if [ "$KONG_CLUSTER_PRIVATE_IP" ]; then
    KONG_CLUSTER_PRIVATE_IP=$(echo $KONG_CLUSTER_PRIVATE_IP | awk '{print $4}' | cut -d/ -f1)
else
    KONG_CLUSTER_PRIVATE_IP='127.0.0.1'
fi
echo "Kong cluster private IP: $KONG_CLUSTER_PRIVATE_IP"
luajit "$SRC_DIR/config/generator.lua" "$SRC_DIR/config/kong.conf.etlua" "$SRC_DIR"

source $SRC_DIR/.profile.d/kong-env
