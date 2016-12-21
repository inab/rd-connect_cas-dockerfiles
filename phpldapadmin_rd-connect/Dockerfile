FROM	rd-connect.eu/httpd:2.4
MAINTAINER Andres Cañada <acanada@cnio.es>
LABEL	Description="PHP base image for RD-Connect" Vendor="CNIO" Version="7"

ARG	LDAP_SERVER=ldap.rd-connect.eu

RUN	yum update -y --setopt=tsflags=nodocs && \
	yum install -y --setopt=tsflags=nodocs mod_php && \
	yum install -y --setopt=tsflags=nodocs phpldapadmin && \
	yum clean all && \
	sed -i  "s#\/\/ \$servers->setValue('login','attr','dn')#\$servers->setValue('login','attr','dn')#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('server','name','Local LDAP Server')#\$servers->setValue('server','name','RD-Connect LDAP Server')#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('server','host','127.0.0.1')#\$servers->setValue('server','host','${LDAP_SERVER}')#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('server','base',array(''))#\$servers->setValue('server','base',array('dc=rd-connect,dc=eu'))#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('login','auth_type','cookie')#\$servers->setValue('login','auth_type','session')#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('server','tls',false)#\$servers->setValue('server','tls',true)#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('login','attr','uid')#\/\/ \$servers->setValue('login','attr','uid')#g" /etc/phpldapadmin/config.php

VOLUME	[ "/etc/phpldapadmin" ]
