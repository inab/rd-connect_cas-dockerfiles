#!/bin/bash

# Directory where the certificates are going to be initially saved
LOCAL_CAS_LDAP_CERTS_DIR=/tmp/rd-connect_cas_ldap_certs
# Sub-directory with the LDAP certificates
LDAP_CERTS_PROFILE=cas-ldap

set -e
if [ ! -f /var/lib/ldap/DB_CONFIG ] ; then
	echo "Initializing LDAP directory"
	
	# Saving the standard output and standard error
	exec 6>&1 7>&2
	exec >> /var/log/init_entrypoint.txt 2>&1

	# First, fetch the certificates
	if [ ! -d "${LOCAL_CAS_LDAP_CERTS_DIR}" ] ; then
		curl -o "${LOCAL_CAS_LDAP_CERTS_DIR}".tar http://${CA_BROKER:-ca.rd-connect.eu}/ca/${LDAP_CERTS_PROFILE}
		mkdir -p "${LOCAL_CAS_LDAP_CERTS_DIR}"
		tar -x -C "${LOCAL_CAS_LDAP_CERTS_DIR}" -f "${LOCAL_CAS_LDAP_CERTS_DIR}".tar
	fi
	
	# Then, initial OpenLDAP setup
	cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
	chown ldap. /var/lib/ldap/DB_CONFIG
	
	# Run the setup script
	bash "${CASCLONE}/ldap-schemas/setup-ldap.sh" "${LOCAL_CAS_LDAP_CERTS_DIR}" "${LDAP_CERTS_PROFILE}" "/etc/init.d/slapd start" '/etc/init.d/slapd stop'
	
	# Doing some certificates cleanup
	rm -rf "${LOCAL_CAS_LDAP_CERTS_DIR}"*
	
	# Restoring the standard output and standard error
	exec 2>&7 1>&6
	exec 7>&- 6>&-
	echo "LDAP directory has been initialized"
fi

# Storing the passwords in the initialization credentials broker
if [ -n "$CRED_BROKER" -a -f /etc/openldap/for_sysadmin.txt ] ; then
	redis-cli -h "$CRED_BROKER" set ldapDomainPass "$(grep '^domainPass' /etc/openldap/for_sysadmin.txt | cut -f 2 -d =)"
fi

# Run the command
exec "$@"