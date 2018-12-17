#!/bin/bash

# Directory where the certificates are going to be initially saved
LOCAL_HTTPD_CERTS_DIR=/tmp/cas-httpd-certs
# Sub-directory with the PHPLDAPAdmin certificates
HTTPD_CERTS_PROFILE=cas-httpd
# The certification authority's public key
CA_CERT=/etc/openldap/certs/cacert.pem

DESTUSER=rdconnect-rest

set -e
if [ ! -f ~${DESTUSER}/RDConnect-UserManagement-REST-API/configs/user-management.ini ] ; then
	echo "Initializing UserManagement"
	
	# Saving the standard output and standard error
	exec 6>&1 7>&2
	exec >> /var/log/init_entrypoint.txt 2>&1

	# First, fetch the certificates
	if [ ! -d "${LOCAL_HTTPD_CERTS_DIR}" ] ; then
		curl -o "${LOCAL_HTTPD_CERTS_DIR}".tar http://${CA_BROKER:-ca.rd-connect.eu}/ca/${HTTPD_CERTS_PROFILE}
		mkdir -p "${LOCAL_HTTPD_CERTS_DIR}"
		tar -x -C "${LOCAL_HTTPD_CERTS_DIR}" -f "${LOCAL_HTTPD_CERTS_DIR}".tar
	fi
	
	# Second, put the certificates in place
	mv "${LOCAL_HTTPD_CERTS_DIR}"/cacert.pem "${CA_CERT}"
	sed -i "/TLS_CACERTDIR/a TLS_CACERT ${CA_CERT}" /etc/openldap/ldap.conf
	
	UMI_SERVER="${HOSTNAME}"
	UMI_CERT=/etc/pki/tls/certs/${UMI_SERVER}.crt
	UMI_KEY=/etc/pki/tls/private/${UMI_SERVER}.key
	mv "${LOCAL_HTTPD_CERTS_DIR}"/"${HTTPD_CERTS_PROFILE}"/cert.pem "${UMI_CERT}"
	mv "${LOCAL_HTTPD_CERTS_DIR}"/"${HTTPD_CERTS_PROFILE}"/key.pem "${UMI_KEY}"
	sed -i "/^#ServerName/a ServerName ${UMI_SERVER}" /etc/httpd/conf/httpd.conf
	sed -i "s#^SSLCertificateFile .*#SSLCertificateFile ${UMI_CERT}#" /etc/httpd/conf.d/ssl.conf
	sed -i "s#^SSLCertificateKeyFile .*#SSLCertificateKeyFile ${UMI_KEY}#" /etc/httpd/conf.d/ssl.conf
	sed -i "/^#SSLCACertificateFile/a SSLCACertificateFile ${CA_CERT}" /etc/httpd/conf.d/ssl.conf

	if [ -z "$CAS_SERVER" ] ; then
		CAS_SERVER=rdconnectcas.rd-connect.eu
	fi
	if [ -z "$CAS_PORT" ] ; then
		CAS_PORT=9443
	fi
	CAS_SERVER_URL=https://${CAS_SERVER}:${CAS_PORT}/cas
	
	if [ -z "$LDAP_SERVER" ] ; then
		LDAP_SERVER=ldap.rd-connect.eu
	fi
	CAS_LDAP_USER="cn=admin,dc=rd-connect,dc=eu"
	# This is a placeholder for the true intermediate LDAP admin password
	CAS_LDAP_PASS=changeit
	# Second, fetch the admin password from the credentials broker
	if [ -n "$CRED_BROKER" ] ; then
		while redis-cli -h "$CRED_BROKER" exists ldapDomainPass | grep -qvF '1' ; do
			echo Waiting for the value at the credential broker
			sleep 1
		done
		CAS_LDAP_PASS="$(redis-cli -h "$CRED_BROKER" get ldapDomainPass)"
		#CAS_LDAP_USER="$(redis-cli -h "$CRED_BROKER" get ldapDomainUser)"
	fi
	
	cd /home/${DESTUSER}/RDConnect-UserManagement-REST-API/configs
	cp -p user-management.ini.template user-management.ini
	sed -i "s/^.*ldap_host=.*/ldap_host=${LDAP_SERVER}/; s/^.*ldap_user=.*/ldap_user=${CAS_LDAP_USER}/; s/^.*ldap_pass=.*/ldap_pass=${CAS_LDAP_PASS}/; s#^cas_url=.*#cas_url=${CAS_SERVER_URL}#;" user-management.ini
	
	# Doing some certificates cleanup
	rm -rf "${LOCAL_HTTPD_CERTS_DIR}"*	

	# Restoring the standard output and standard error
	exec 2>&7 1>&6
	exec 7>&- 6>&-
	echo "UserManagement has been initialized"
fi

# Run the command
exec "$@"