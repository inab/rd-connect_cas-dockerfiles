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

tempF="$(tempfile)"
docker cp "${prefix}"casldap:/etc/openldap/for_sysadmin.txt "$tempF"
casPass="$(grep '^rootPass' "$tempF" | cut -f 2 -d =)"
domainPass="$(grep '^domainPass' "$tempF" | cut -f 2 -d =)"
rm -f "${tempF}"

tempF="$(tempfile)"
docker cp "${prefix}"cas:/etc/tomcat7/tomcat-users.xml "$tempF"
tomcatUser="$(grep '<user .*manager-gui' "$tempF" | grep -o "name='[^']*'" | cut -f 2 -d "'")"
tomcatPass="$(grep '<user .*manager-gui' "$tempF" | grep -o "password='[^']*'" | cut -f 2 -d "'")"
rm -f "${tempF}"

echo "Tomcat manager Credentials => user: $tomcatUser; password: $tomcatPass"
echo "CAS Credentials => user: platform@rd-connect.eu ; password: $casPass"
echo "PLA Credentials => user: cn=admin,dc=rd-connect,dc=eu ; password: $domainPass"

docker_start_instances "${prefix}"

echo
echo "To stop the instances, run ./stopInstances.sh ${prefix}"
echo "To remove the instances, run ./removeInstances.sh ${prefix}"
echo "To drop the data volumes, run ./dropDataVolumes.sh ${prefix}"
