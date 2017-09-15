FROM	rd-connect.eu/httpd:2.4
LABEL	description="PHP base image for RD-Connect" vendor="BSC-CNS" version="7" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

ARG	LDAP_SERVER=ldap.rd-connect.eu
ARG	PLA_SERVER=rdconnect-pla.rd-connect.eu

ARG	HTTPD_CERTS_FILE=/tmp/cas-pla-certs.tar
ARG	HTTPD_CERTS_PROFILE=cas-pla
ENV	LOCAL_HTTPD_CERTS_DIR=/tmp/rd-connect_pla_certs

RUN	yum update -y --setopt=tsflags=nodocs && \
	yum install -y --setopt=tsflags=nodocs mod_php && \
	yum install -y --setopt=tsflags=nodocs phpldapadmin && \
	yum clean all && rm -rf /var/cache/yum

# Setting up the CA certificate and server certificates (very important!)
ADD	"${HTTPD_CERTS_FILE}" "${LOCAL_HTTPD_CERTS_DIR}"
ENV	CA_CERT=/etc/openldap/certs/cacert.pem
RUN	mv "${LOCAL_HTTPD_CERTS_DIR}"/cacert.pem "${CA_CERT}"
RUN	sed -i "/TLS_CACERTDIR/a TLS_CACERT ${CA_CERT}" /etc/openldap/ldap.conf

# Allowing accessing the server from outside 127.0.0.1
ENV	PLA_CERT=/etc/pki/tls/certs/${PLA_SERVER}.crt
ENV	PLA_KEY=/etc/pki/tls/private/${PLA_SERVER}.key
RUN	mv "${LOCAL_HTTPD_CERTS_DIR}"/"${HTTPD_CERTS_PROFILE}"/cert.pem "${PLA_CERT}" && \
	mv "${LOCAL_HTTPD_CERTS_DIR}"/"${HTTPD_CERTS_PROFILE}"/key.pem "${PLA_KEY}"
RUN	sed -i "/^#ServerName/a ServerName ${PLA_SERVER}" /etc/httpd/conf/httpd.conf
RUN	sed -i "s#^SSLCertificateFile .*#SSLCertificateFile ${PLA_CERT}#" /etc/httpd/conf.d/ssl.conf && \
	sed -i "s#^SSLCertificateKeyFile .*#SSLCertificateKeyFile ${PLA_KEY}#" /etc/httpd/conf.d/ssl.conf && \
	sed -i "/^#SSLCACertificateFile/a SSLCACertificateFile ${CA_CERT}" /etc/httpd/conf.d/ssl.conf
RUN	sed -i "s#Require local#Require all granted#;" /etc/httpd/conf.d/phpldapadmin.conf

# Setting up phpLDAPadmin
RUN	sed -i  "s#\$servers->setValue('server','name','Local LDAP Server')#\$servers->setValue('server','name','RD-Connect LDAP Server')#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('login','attr','uid')#\$servers->setValue('login','attr','dn')#g" /etc/phpldapadmin/config.php && \
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('server','host','${LDAP_SERVER}');" /etc/phpldapadmin/config.php && \
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('server','base',array('dc=rd-connect,dc=eu'));" /etc/phpldapadmin/config.php && \
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('login','auth_type','session');" /etc/phpldapadmin/config.php && \
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('server','tls',true);" /etc/phpldapadmin/config.php && \
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('server','port',389);" /etc/phpldapadmin/config.php && \
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('login','bind_id','');" /etc/phpldapadmin/config.php && \
	sed -i  "/RD-Connect LDAP Server/a \$servers->setValue('login','bind_pass','');" /etc/phpldapadmin/config.php

VOLUME	[ "/etc/phpldapadmin", "/etc/openldap", "/etc/pki/tls" ]
