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

#source the profile file now it's been updated with CC client bin in PATH
. $HOME/.sag/profile

## we may want to add that to the .bashrc file for auto sourcing on login