#!/bin/sh

set -e

if [ $# -gt 0 ] ; then
	archiveFile="$1"
	shift

	dockerFileDir="$(dirname "$0")"
	case "${dockerFileDir}" in
		/*)
			true
			;;
		*)
			dockerFileDir="${PWD}"/"${dockerFileDir}"
			;;
	esac

	source "${dockerFileDir}"/declDataVolumes.sh.common
	
	docker_save_images "${archiveFile}"
	echo
	echo "To create the data volumes, run ./initDataVolumes.sh ${origPrefix}"
	echo "To populate the data volumes, run ./populateDataVolumes.sh ${origPrefix}"
	echo "To create the instances, run ./createInstances.sh ${origPrefix}"
	echo "To start the instances, run ./startInstances.sh ${origPrefix}"
else
	echo "Usage: $0 {dest_archive}" 1>&2
	exit 1
fi

