#!/bin/bash
TEST_PATH="$( cd "$(dirname "$0")" ; pwd -P )"
export QHOME="/storage/johan/kx/rel/q"

export QSERV_HOME="/home/johan/kx/QServ"
export KDB_SVC_CONFIG_PATH="${QSERV_HOME}/config/svc"
export KDB_COMMON_CONFIG_PATH="${QSERV_HOME}/config/common"


### Start the discovery service
pushd ${QSERV_HOME}/src/q/discovery
$QHOME/l32/q discovery.q &
DISCOVERY_PID=$!
popd

pushd ${TEST_PATH}
## Start the mult test server
$QHOME/l32/q multService.q &
MULT_SVC_PID=$!

#Wait for the mult server to start and register its funtions in discovery
sleep 2 ## TODO: change this to check the discovery service instead.


$QHOME/l32/q testDiscovery.q

kill -9 $DISCOVERY_PID
kill -9 $MULT_SVC_PID

popd
