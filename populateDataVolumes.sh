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

# Loop and print it.  Using offset and length to extract values
for ((iVol=0; iVol<$numVolumes; iVol++)) ; do
	origInstanceName="${!volumes[iVol]:0:1}"
	instanceName="${prefix}${origInstanceName}"
	volumeName="${prefix}${!volumes[iVol]:1:1}"
	mountPoint="${!volumes[iVol]:2:1}"
	imageName="${images[$origInstanceName]}"
	
	# This is to be sure the volume does exist
	docker volume create --name "${volumeName}"
	#docker run --rm -v "${volumeName}":"${tvol}" "$imageName" /bin/bash -c "ls /"
	#docker run --rm -v "${volumeName}":"${tvol}" "$imageName" /bin/bash -c "cp -aT '${mountPoint}' '${tvol}' && chown '--reference=${mountPoint}' '${tvol}' && chmod '--reference=${mountPoint}' '${tvol}' && ls -la '${tvol}'"
	docker run --rm -v "${volumeName}":"${tvol}" "$imageName" /bin/bash -c "cp -aT '${mountPoint}' '${tvol}' && chown '--reference=${mountPoint}' '${tvol}' && chmod '--reference=${mountPoint}' '${tvol}'"
done


echo "To drop the data volumes, run ./dropDataVolumes.sh ${prefix}"
echo "To create the instances, run ./createInstances.sh ${prefix}"
