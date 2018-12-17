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

# This is a data container needed by CA
cd "${dockerFileDir}"

# From this point, any failure will stop the batch script
set -e

# Sourcing the environment variables
source .env
if [ -z "${DOMAIN}" ] ; then
	DOMAIN=rd-connect.eu
fi
docker-compose build