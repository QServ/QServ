#!/bin/bash
TEST_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

export QHOME="/storage/johan/kx/rel/q"

export QSERV_HOME="/home/johan/kx/QServ"
export KDB_SVC_CONFIG_PATH="${TEST_PATH}/svc_config"
export KDB_COMMON_CONFIG_PATH="${TEST_PATH}/common_config"


### Run the test service
pushd ${TEST_PATH}

${QHOME}/l32/q testConfigManager.q


