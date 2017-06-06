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

docker_stop_instances "${prefix}"

echo
echo "To start the instances again, run ./startInstances.sh ${origPrefix}"
echo "To remove the instances, run ./removeInstances.sh ${origPrefix}"
echo "To drop the data volumes, run ./dropDataVolumes.sh ${origPrefix}"
