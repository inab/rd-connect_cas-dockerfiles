FROM	rd-connect.eu/httpd:2.4
MAINTAINER Andres Cañada <acanada@cnio.es>
LABEL	Description="PHP base image for RD-Connect" Vendor="CNIO" Version="7"

ARG	LDAP_SERVER=ldap.rd-connect.eu
ARG	UMI_SERVER=rdconnect-umi.rd-connect.eu

ARG	HTTPD_CERTS_FILE=/tmp/cas-httpd-certs.tar
ARG	HTTPD_CERTS_PROFILE=cas-httpd
ENV	LOCAL_HTTPD_CERTS_DIR=/tmp/rd-connect_umi_certs

RUN	yum update -y --setopt=tsflags=nodocs && \
	yum install -y --setopt=tsflags=nodocs mod_php && \
	yum install -y --setopt=tsflags=nodocs phpldapadmin && \
	yum clean all

# Setting up the CA certificate and server certificates (very important!)
ADD	"${HTTPD_CERTS_FILE}" "${LOCAL_HTTPD_CERTS_DIR}"
ENV	CA_CERT=/etc/openldap/certs/cacert.pem
RUN	mv "${LOCAL_HTTPD_CERTS_DIR}"/cacert.pem "${CA_CERT}"
RUN	sed -i "/TLS_CACERTDIR/a TLS_CACERT ${CA_CERT}" /etc/openldap/ldap.conf

# Allowing accessing the server from outside 127.0.0.1
ENV	UMI_CERT=/etc/pki/tls/certs/${UMI_SERVER}.crt
ENV	UMI_KEY=/etc/pki/tls/private/${UMI_SERVER}.key
RUN	mv "${LOCAL_HTTPD_CERTS_DIR}"/"${HTTPD_CERTS_PROFILE}"/cert.pem "${UMI_CERT}" && \
	mv "${LOCAL_HTTPD_CERTS_DIR}"/"${HTTPD_CERTS_PROFILE}"/key.pem "${UMI_KEY}"
RUN	sed -i "/^#ServerName/a ServerName ${UMI_SERVER}" /etc/httpd/conf/httpd.conf
RUN	sed -i "s#^SSLCertificateFile .*#SSLCertificateFile ${UMI_CERT}#" /etc/httpd/conf.d/ssl.conf && \
	sed -i "s#^SSLCertificateKeyFile .*#SSLCertificateKeyFile ${UMI_KEY}#" /etc/httpd/conf.d/ssl.conf && \
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

VOLUME	[ "/etc/phpldapadmin", "/etc/openldap", "/etc/pki/certs" ]
