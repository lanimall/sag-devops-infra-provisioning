#!/bin/bash

SAGCCANT_CMD="sagccant"
CC_CLIENT=default
TARGET_HOST=sagdevops_ccinfra_is

## env variables
export db_name="XE"
export db_sid="XE"
export db_type="oracle"
export db_host="sagdevops_ccinfra_db"
export db_port="1521"
#no need to pass the tablespace dir if db_create_file_dest is set on the target database
#export db_tablespace_dir="/u01/app/oracle/oradata/XE"
export db_tablespace_data="WEBMDATA"
export db_tablespace_index="WEBMINDX"
export db_admin_username="sagdb_admin"
export db_admin_password="Wee!BdXr8Gf9*6e8"
export db_username="bpm_dbuser"
export db_password="strong123!"
export db_product_version="latest"
export db_component_version="latest"
export db_components="[STR]"
export db_products="[BPM]"

##### apply um template
$SAGCCANT_CMD -Denv.CC_CLIENT=$CC_CLIENT \
              -Denv.CC_TEMPLATE=dbcreator \
              -Denv.CC_TEMPLATE_ENV=dbcreator \
              -Denv.CC_TEMPLATE_ENV_TARGET_HOST=$TARGET_HOST \
              -Denv.CC_TEMPLATE_ENV_TYPE=server \
              -Denv.SOCKET_CHECK_TARGET_HOST=$TARGET_HOST \
              -Denv.SOCKET_CHECK_TARGET_PORT=22 \
              setup