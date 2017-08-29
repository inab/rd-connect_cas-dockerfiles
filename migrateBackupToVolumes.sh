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

echo "INFO: To drop the generated data volumes, run ./dropDataVolumes.sh '${origPrefix}'"


if [ $# -ge 3 ] ; then
	backupArchive="$1"
	mappingsFile="$2"
	transfersFile="$3"
	
	# Check whether the file exists
	if [ -r "${backupArchive}" -a -r "${mappingsFile}" -a -r "${transfersFile}" ] ; then
		echo "INFO: Testing the integrity of the backup archive"
		gunzip -t "${backupArchive}"
		
		# We need to give an absolute path to docker with no colons (sigh)
		case "${backupArchive}" in
			*\:*)
				echo "ERROR: due Docker command-line limitations, filenames cannot contain colons" 1>&2
				exit 1
				;;
			/*)
				true
				;;
			*)
				backupArchive="${PWD}"/"${backupArchive}"
				;;
		esac
		#lnBackupArchive="/tmp/mig_${RANDOM}_$(date +%s).tar.gz"
		#ln -s "${backupArchive}" "${lnBackupArchive}"
		
		tvol=/tmp/volmnt
		
		echo "INFO: Populating data volumes with combined data"
		docker_migrate_volumes "${prefix}" "${backupArchive}" "${mappingsFile}" "${transfersFile}" "${tvol}"
		
		echo "To create the instances, run ./createInstances.sh ${origPrefix}"
	else
		echo "ERROR: backup archive $backupArchive, mappings file ${mappingsFile} or transfers file ${transfersFile} do not exist!" 1>&2
		exit 1
	fi
else
	echo "Usage: $0 {migrated volumes prefix} {backup archive} {mappings file} {transfers file}"
fi
