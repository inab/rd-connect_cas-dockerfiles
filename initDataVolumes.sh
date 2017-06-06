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

echo "Using prefix '${prefix}' for data volumes"

docker_init_volumes "${prefix}"

echo "To populate the volumes, run ./populateDataVolumes.sh ${origPrefix}"
echo "To drop the data volumes, run ./dropDataVolumes.sh ${origPrefix}"
