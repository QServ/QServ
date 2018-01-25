#!/bin/bash
TEST_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

export KDB_SVC_CONFIG_PATH="${QSERV_HOME}/config/svc"
export KDB_COMMON_CONFIG_PATH="${QSERV_HOME}/config/common"


### Start the discovery service
pushd ${QSERV_HOME}/src/q/discovery
$QHOME/l32/q discovery.q &
DISCOVERY_PID=$!
popd

## Start the mult test server
pushd ${QSERV_HOME}/src/q/log
$QHOME/l32/q logServer.q &
LOG_SVC_PID=$!
popd

#Wait for the log server to start and register its log funtions in discovery
sleep 2 ## TODO: change this to check the discovery service instead.

pushd ${TEST_PATH}
$QHOME/l32/q testLogServer.q

kill -9 $DISCOVERY_PID
kill -9 $LOG_SVC_PID

popd
