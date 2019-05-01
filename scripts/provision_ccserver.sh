#!/bin/bash

ANT_CMD="ant"

CC_BOOT=default
SPM_INSTALL_DIR=/opt/softwareag104

## first, make sure ant is installed
sudo yum -y install ant

#not sure how to use the -f sagdevops-cc-server/build.xml command with sagccant
##### bootstrap: this leverages the ENV
## for security, CC_PASSWORD should be defined in the shell
$ANT_CMD -Denv.CC_BOOT=$CC_BOOT -Denv.CC_PASSWORD=$CC_PASSWORD -Dinstall.dir=$SPM_INSTALL_DIR boot

# once done, make sure to run this script to install SPM as a service
sudo sh $SPM_INSTALL_DIR/bin/afterInstallAsRoot.sh

#re-source the bashrc file now it's been updated with CC client bin in PATH
. $HOME/.bashrc