#!/bin/bash

dockerFileDir="$(dirname "$0")"
case "${dockerFileDir}" in
	/*)
		true
		;;
	*)
		dockerFileDir="${PWD}"/"${dockerFileDir}"
		;;
esac

# From this point, any failure will stop the batch script
set -e

source "${dockerFileDir}"/declDataVolumes.sh.common

echo "Using prefix '${prefix}' for data volumes and instances"

HOST_CASPORT=9443
HOST_UMIPORT=9444
HOST_PLAPORT=9445
if [ $# -gt 0 ] ; then
	HOST_UMIPORT="$1"
	if [ $# -gt 1 ] ; then
		HOST_CASPORT="$2"
		if [ $# -gt 2 ] ; then
			HOST_PLAPORT="$2"
		fi
	fi
fi

#############################
# Creating docker instances #
# using the prefix and     #
# attaching the volumes   #
##########################

docker_create "${prefix}" casldap
docker_create "${prefix}" cas $HOST_CASPORT 9443
docker_create "${prefix}" pla $HOST_PLAPORT 443
docker_create "${prefix}" umi $HOST_UMIPORT 443

echo "When you start the instances:"
echo "* RD-Connect CAS Tomcat manager app is available at https://127.0.0.1:$HOST_CASPORT/manager/html"
echo "* RD-Connect CAS is available at https://127.0.0.1:$HOST_CASPORT/cas/login"
echo "* RD-Connect UMI is available at https://127.0.0.1:$HOST_UMIPORT/user-management/"
echo "* RD-Connect phpLDAPadmin is available at https://127.0.0.1:$HOST_PLAPORT/phpldapadmin/"
echo
echo "To start the instances, run ./startInstances.sh ${origPrefix}"
echo "To remove the instances, run ./removeInstances.sh ${origPrefix}"
echo "To drop the data volumes, run ./dropDataVolumes.sh ${origPrefix}"
