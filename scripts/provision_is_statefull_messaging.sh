#!/bin/bash

SAGCCANT_CMD="sagccant"
CC_CLIENT=default
TARGET_HOST=sagdevops_ccinfra_is

## env variables
export db_type="oracle"
export db_name="XE"
export db_sid="XE"
export db_host="sagdevops_ccinfra_db"
export db_port="1521"
export db_username="is_dbuser"
export db_password="strong123!"

##### apply um template
$SAGCCANT_CMD -Denv.CC_CLIENT=$CC_CLIENT \
              -Denv.CC_TEMPLATE=is-layer/tpl_is_stateful_messaging.yaml \
              -Denv.CC_TEMPLATE_ENV=is_stateful_messaging \
              -Denv.CC_TEMPLATE_ENV_TARGET_HOST=$TARGET_HOST \
              -Denv.CC_TEMPLATE_ENV_TYPE=server \
              -Denv.SOCKET_CHECK_TARGET_HOST=$TARGET_HOST \
              -Denv.SOCKET_CHECK_TARGET_PORT=22 \
              setup