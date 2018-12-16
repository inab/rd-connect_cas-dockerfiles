#!/bin/bash

# Directory where the certificates are going to be initially saved
LOCAL_CAS_TOMCAT_CERTS_DIR=/tmp/rd-connect_cas_tomcat_certs
# Sub-directory with the CAS certificates
CAS_CERTS_PROFILE=cas-tomcat

set -e
if [ ! -f "/etc/cas/cas.properties" ] ; then
	echo "Initializing CAS + CAS Management"
	
	# Saving the standard output and standard error
	exec 6>&1 7>&2
	exec >> /var/log/init_entrypoint.txt 2>&1

	# First, fetch the certificates
	if [ ! -d "${LOCAL_CAS_TOMCAT_CERTS_DIR}" ] ; then
		curl -o "${LOCAL_CAS_TOMCAT_CERTS_DIR}".tar http://${CA_BROKER:-ca.rd-connect.eu}/ca/${CAS_CERTS_PROFILE}
		mkdir -p "${LOCAL_CAS_TOMCAT_CERTS_DIR}"
		tar -x -C "${LOCAL_CAS_TOMCAT_CERTS_DIR}" -f "${LOCAL_CAS_TOMCAT_CERTS_DIR}".tar
	fi
	
	# This is a placeholder for the true intermediate LDAP admin password
	CAS_LDAP_PASS=changeit
	
	# Second, fetch the admin password from the credentials broker
	# TODO
	if [ -n "$CRED_BROKER" ] ; then
		while redis-cli -h "$CRED_BROKER" exists ldapDomainPass | grep -qvF '1' ; do
			echo Waiting for the value at the credential broker
			sleep 1
		done
		CAS_LDAP_PASS="$(redis-cli -h "$CRED_BROKER" get ldapDomainPass)"
	fi

	
	if [ -z "$LDAP_SERVER" ] ; then
		LDAP_SERVER=ldap.rd-connect.eu
	fi
	
	# Third, initialize Tomcat+CAS installation
	/bin/bash -x "/tmp/cas-repo/etc/setup-cas-tomcat.sh" "${LOCAL_CAS_TOMCAT_CERTS_DIR}" "${CAS_CERTS_PROFILE}" "${CAS_LDAP_PASS}" '/etc/sysconfig/tomcat8'
	
	# Fourth, initialize CAS Management installation
	#install -D -o tomcat -g tomcat -m 644 /tmp/cas-mgmt-repo/etc/log4j2-cas-management.system.xml /etc/cas/log4j2-cas-management.xml
	
	# Doing some certificates cleanup
	rm -rf "${LOCAL_HTTPD_CERTS_DIR}"*
	
	# And removing the repos, as they are not needed any more
	#rm -rf /tmp/cas-*
	
	# Restoring the standard output and standard error
	exec 2>&7 1>&6
	exec 7>&- 6>&-
	echo "CAS+CAS Management have been initialized"
fi

chown -R tomcat: /var/log/cas

# Run the command
exec "$@"