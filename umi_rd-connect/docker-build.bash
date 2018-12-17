#!/bin/bash

set -e

export NODE_VERSION=8.14.0
DESTUSER=rdconnect-rest
if [ $# -ge 3 ] ; then
	USERMANAGEMENT_CHECKOUT="$1"
	UMI_CHECKOUT="$2"
	REQS_UI_CHECKOUT="$3"

	# Installing the UMI pre-requisites

	yum install -y --setopt=tsflags=nodocs epel-release git
	yum install -y --enablerepo=epel --setopt=tsflags=nodocs apg redis

	# These dependencies are needed to install modules
	yum install -y --setopt=tsflags=nodocs gcc gcc-c++ automake flex \
	bison make patch perl perl-devel perl-core perl-Net-IDN-Encode \
	openssl-devel libxml2-devel perl-LWP-Protocol-https
	
	# User was created to host the application
	useradd -m -U -c 'RD-Connect REST API unprivileged user' "${DESTUSER}"
	
	# Now, run the build job as the destination user
	su -c "/tmp/docker-umi-build.bash $USERMANAGEMENT_CHECKOUT $UMI_CHECKOUT $REQS_UI_CHECKOUT $NODE_VERSION" - "${DESTUSER}"
	
	# Configure apache for application
	# Enabling the API as such, running as the destination user
	sed -i "s#{DESTUSER}#${DESTUSER}#g" /tmp/umi.conf
	sed -e '/<\/VirtualHost>/r /tmp/umi.conf' -e 'x;$G' -i /etc/httpd/conf.d/ssl.conf
	rm /tmp/umi.conf
	
	# Cleaning up, root level
	yum autoremove -y git gcc gcc-c++ automake flex bison make patch
	yum clean all && rm -rf /var/cache/yum
else
	echo "ERROR: Incorrect number of parameters" 1>&2
	exit 1
fi
