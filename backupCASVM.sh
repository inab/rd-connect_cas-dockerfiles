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

# We do not want it eats the CAS VM hostname!!!!
skipPrefixProcessing=1
source "${dockerFileDir}"/declDataVolumes.sh.common

if [ $# -ge 1 ] ; then
	cas_hostname="$1"
	if [ $# -ge 2 ] ; then
		destfile="$2"
	else
		destfile="cas-backup-$(date -Is).tar.gz"
	fi
	
	backup_cas_vm "$cas_hostname" "$destfile"

	#echo "To drop the data volumes, run ./dropDataVolumes.sh ${origPrefix}"
	#echo "To create the instances, run ./createInstances.sh ${origPrefix}"
else
	echo "Usage: $0 {CAS VM hostname} [destination archive]"
fi
