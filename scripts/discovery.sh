#! /bin/bash

export KDB_SVC_CONFIG_PATH="${QSERV_HOME}/config/svc"
export KDB_COMMON_CONFIG_PATH="${QSERV_HOME}/config/common"

pushd "${QSERV_HOME}/src/q/discovery"
$QHOME/l32/q discovery.q 
popd
