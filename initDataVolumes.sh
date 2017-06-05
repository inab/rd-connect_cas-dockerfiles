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

# Loop and print it.  Using offset and length to extract values
for ((iVol=0; iVol<$numVolumes; iVol++)) ; do
	#instanceName="${prefix}${!volumes[iVol]:0:1}"
	volumeName="${prefix}${!volumes[iVol]:1:1}"
	#mountPoint="${!volumes[iVol]:2:1}"
	docker volume create --name "${volumeName}"
done

echo "To populate the volumes, run ./populateDataVolumes.sh ${prefix}"
echo "To drop the data volumes, run ./dropDataVolumes.sh ${prefix}"
