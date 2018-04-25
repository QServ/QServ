#!/bin/bash

TEST_PATH="$( cd "$(dirname "$0")" ; pwd -P )"

export KDB_SVC_CONFIG_PATH="${TEST_PATH}/svc_config"
export KDB_COMMON_CONFIG_PATH="${TEST_PATH}/common_config"

### Run the test service
pushd ${TEST_PATH}
mkdir logs -p
echo "************** Running File logger tests *****************"
${QHOME}/l32/q testFileLogger.q
mkdir db -p
echo "************** Running DB logger tests *****************"
${QHOME}/l32/q testDbLogger.q db

popd
