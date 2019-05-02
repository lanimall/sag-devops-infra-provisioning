#!/bin/bash

ANT_CMD="ant"

CC_BOOT=default
SPM_INSTALL_DIR=/opt/softwareag

## first, make sure ant is installed
sudo yum -y install ant

# bootstrap the SPM agent
$ANT_CMD -Denv.CC_BOOT=$CC_BOOT -Denv.CC_PASSWORD=$CC_PASSWORD -Dinstall.dir=$SPM_INSTALL_DIR agent

# once done, make sure to run this script to install SPM as a service
sudo sh $SPM_INSTALL_DIR/bin/afterInstallAsRoot.sh

#update the bash profile file to include the newly installed CLI in the PATH
echo "CC_CLI_HOME=${SPM_INSTALL_DIR}/CommandCentral/client" >> ${HOME}/.bashrc
echo "export PATH=\$PATH:\${CC_CLI_HOME}/bin" >> ${HOME}/.bashrc
. ${HOME}/.bashrc