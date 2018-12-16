#!/bin/bash

# Directory where the certificates are going to be initially saved
LOCAL_HTTPD_CERTS_DIR=/tmp/rd-connect_pla_certs
# Sub-directory with the PHPLDAPAdmin certificates
HTTPD_CERTS_PROFILE=cas-pla
# The certification authority's public key
CA_CERT=/etc/openldap/certs/cacert.pem

set -e
if [ ! -f "${CA_CERT}" ] ; then
	echo "Initializing PHPLDAPAdmin"
	
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

	if [ -z "$PLA_SERVER" ] ; then
		PLA_SERVER=rdconnect-pla.rd-connect.eu
	fi
	
	if [ -z "$LDAP_SERVER" ] ; then
		LDAP_SERVER=ldap.rd-connect.eu
	fi
	
	# Allowing accessing the server from outside 127.0.0.1
	sed -i "/^#ServerName/a ServerName ${PLA_SERVER}" /etc/httpd/conf/httpd.conf
	
	PLA_CERT=/etc/pki/tls/certs/${PLA_SERVER}.crt
	PLA_KEY=/etc/pki/tls/private/${PLA_SERVER}.key
	mv "${LOCAL_HTTPD_CERTS_DIR}"/"${HTTPD_CERTS_PROFILE}"/cert.pem "${PLA_CERT}"
	mv "${LOCAL_HTTPD_CERTS_DIR}"/"${HTTPD_CERTS_PROFILE}"/key.pem "${PLA_KEY}"
	
	sed -i "s#^SSLCertificateFile .*#SSLCertificateFile ${PLA_CERT}#" /etc/httpd/conf.d/ssl.conf
	sed -i "s#^SSLCertificateKeyFile .*#SSLCertificateKeyFile ${PLA_KEY}#" /etc/httpd/conf.d/ssl.conf
	sed -i "/^#SSLCACertificateFile/a SSLCACertificateFile ${CA_CERT}" /etc/httpd/conf.d/ssl.conf
	
	sed -i "s#Require local#Require all granted#;" /etc/httpd/conf.d/phpldapadmin.conf

	# Setting up phpLDAPadmin
	sed -i  "s#\$servers->setValue('server','name','Local LDAP Server')#\$servers->setValue('server','name','RD-Connect LDAP Server')#g" /etc/phpldapadmin/config.php
	sed -i  "s#\$servers->setValue('login','attr','uid')#\$servers->setValue('login','attr','dn')#g" /etc/phpldapadmin/config.php
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('server','host','${LDAP_SERVER}');" /etc/phpldapadmin/config.php
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('server','base',array('dc=rd-connect,dc=eu'));" /etc/phpldapadmin/config.php
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('login','auth_type','session');" /etc/phpldapadmin/config.php
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('server','tls',true);" /etc/phpldapadmin/config.php
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('server','port',389);" /etc/phpldapadmin/config.php
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('login','bind_id','');" /etc/phpldapadmin/config.php
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('login','bind_pass','');" /etc/phpldapadmin/config.php
	
	# Doing some certificates cleanup
	rm -rf "${LOCAL_HTTPD_CERTS_DIR}"*
	
	# Restoring the standard output and standard error
	exec 2>&7 1>&6
	exec 7>&- 6>&-
	echo "PHPLDAPAdmin has been initialized"
fi

# Run the command
exec "$@"