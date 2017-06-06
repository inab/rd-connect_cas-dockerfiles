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

tvol=/tmp/volmnt

docker_populate_volumes "${prefix}" "${tvol}"

echo "To drop the data volumes, run ./dropDataVolumes.sh ${origPrefix}"
echo "To create the instances, run ./createInstances.sh ${origPrefix}"
