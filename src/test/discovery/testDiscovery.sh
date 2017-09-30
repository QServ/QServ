#!/bin/bash
export QHOME="/storage/johan/kx/rel/q"

export QSERV_HOME="/home/johan/kx/QServ"
export KDB_SVC_CONFIG_PATH="${QSERV_HOME}/config/svc"
export KDB_COMMON_CONFIG_PATH="${QSERV_HOME}/config/common"


### Start the discovery service
pushd ../../q/discovery/
$QHOME/l32/q discovery.q &
DISCOVERY_PID=$!
popd

//Start the mult test server
$QHOME/l32/q multService.q &
MULT_SVC_PID=$!

$QHOME/l32/q testDiscovery.q

kill -9 $DISCOVERY_PID
kill -9 $MULT_SVC_PID
