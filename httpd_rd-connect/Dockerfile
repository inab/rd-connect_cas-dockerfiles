FROM	rd-connect.eu/centos:7
MAINTAINER Andres Cañada <acanada@cnio.es>
LABEL	Description="Apache web server base image for RD-Connect" Vendor="CNIO" Version="7"

#RUN rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

# This must be done BEFORE, so /etc/sysconfig/httpd file from CentOS is not overwritten
RUN	cd /root/blfs-bootscripts && make install-httpd && \
	rm -f /etc/sysconfig/httpd && \
	rm -f /etc/sysconfig/htcacheclean
RUN	echo '[program:httpd]' > /etc/supervisord.d/httpd.conf && echo 'command=/my_initd_service httpd' >> /etc/supervisord.d/httpd.conf
RUN yum -y --setopt=tsflags=nodocs update && \
    yum -y --setopt=tsflags=nodocs install httpd mod_ssl openssl && \
	#yum -y install php56w php56w-opcache && \
	yum -y install mod_php \
	yum clean all
RUN sed -i 's#UserDir disabled#\#UserDir disabled#g' /etc/httpd/conf.d/userdir.conf && \
	sed -i 's#\#UserDir public_html#UserDir public_html#g' /etc/httpd/conf.d/userdir.conf
RUN yum -y install phpldapadmin && \
	sed -i  "s#\/\/ \$servers->setValue('login','attr','dn')#\$servers->setValue('login','attr','dn')#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('server','name','Local LDAP Server')#\$servers->setValue('server','name','RD-Connect LDAP Server')#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('server','host','127.0.0.1')#\$servers->setValue('server','host','ldap.rd-connect.eu')#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('server','base',array(''))#\$servers->setValue('server','base',array('dc=rd-connect,dc=eu'))#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('login','auth_type','cookie')#\$servers->setValue('login','auth_type','session')#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('server','tls',false)#\$servers->setValue('server','tls',true)#g" /etc/phpldapadmin/config.php && \
	sed -i  "s#\$servers->setValue('login','attr','uid')#\/\/ \$servers->setValue('login','attr','uid')#g" /etc/phpldapadmin/config.php

EXPOSE 80
