#!/bin/bash

set -e

USERMANAGEMENT_CHECKOUT="$1"
UMI_CHECKOUT="$2"
REQS_UI_CHECKOUT="$3"
NODE_VERSION="$4"

cd /tmp
# # Next block is only needed if nodejs is built from source
# yum update -y --setopt=tsflags=nodocs
# wget -nv https://nodejs.org/download/release/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.xz
# tar xf node-v${NODE_VERSION}.tar.xz
# cd node-v${NODE_VERSION}
# ./configure
# make -j 4
# make install
# rm -rf /tmp/node-v*

# Next block is only needed when a pre-compiled nodejs is used
wget -nv https://nodejs.org/download/release/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz
tar xf node-v${NODE_VERSION}-*.tar.xz

export NODE_HOME=$(echo /tmp/node-v${NODE_VERSION}-*/)
PATH="${NODE_HOME}/bin:$PATH"

# The user management libraries and REST API
cd "${HOME}"
git clone https://github.com/inab/rd-connect-user-management.git
cd rd-connect-user-management
git checkout "${USERMANAGEMENT_CHECKOUT}"
./install-deps.sh

# The requests interface
cd "${HOME}"
git clone https://github.com/inab/rd-connect-requests-interface.git
cd rd-connect-requests-interface
git checkout "${REQS_UI_CHECKOUT}"
npm install --no-save
PATH="${PWD}/node_modules/.bin:$PATH"
webpack -p
cp -dpTr build ../rd-connect-user-management/static_requests

# Now, install the combo
cd "${HOME}"
# Either a symlink
ln -s rd-connect-user-management RDConnect-UserManagement-REST-API
cd "${HOME}"/rd-connect-user-management
# Or a copy
#mkdir -p "${HOME}"/RDConnect-UserManagement-REST-API
#cp -dpr configs static_requests user-management.cgi user-management.fcgi user-management.psgi libs .plEnv "$HOME"/RDConnect-UserManagement-REST-API
cp template-config.ini "$HOME"/RDConnect-UserManagement-REST-API/configs/user-management.ini.template

cd "${HOME}"
git clone https://github.com/inab/rd-connect-user-management-interface.git
cd rd-connect-user-management-interface
git checkout "${UMI_CHECKOUT}"
npm install --no-save
PATH="${PWD}/node_modules/.bin:$PATH"
webpack -p
mkdir -p "$HOME/DOCUMENT_ROOT" && cp -dpTr build "$HOME/DOCUMENT_ROOT/user-management"

chmod go+rx "$HOME"
# The SELinux part
#RUN	chcon -Rv --type=httpd_sys_content_t "$HOME"/DOCUMENT_ROOT && \
#	chcon -Rv --type=httpd_sys_content_t "$HOME"/rd-connect-user-management && \
#	chcon -Rv --type=httpd_sys_content_t "$HOME"/RDConnect-UserManagement-REST-API && \
#	chcon -Rv --type=httpd_sys_script_exec_t "$HOME"/RDConnect-UserManagement-REST-API/user-management.cgi

# Cleaning up, user level. As there are user management scripts, this repo is kept
cd "${HOME}"
rm -rf rd-connect-user-management-interface rd-connect-requests-interface .npm .cpan .cpanm
