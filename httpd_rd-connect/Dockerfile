FROM	rd-connect.eu/centos:7
LABEL	description="Apache web server base image for RD-Connect" vendor="BSC-CNS" version="2.4" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

# This must be done BEFORE, so /etc/sysconfig/httpd file from CentOS is not overwritten
RUN	cd /root/blfs-bootscripts && make install-httpd && \
	rm -f /etc/sysconfig/httpd && \
	rm -f /etc/sysconfig/htcacheclean
RUN	echo '[program:httpd]' > /etc/supervisord.d/httpd.conf && echo 'command=/my_initd_service httpd' >> /etc/supervisord.d/httpd.conf
RUN	yum -y --setopt=tsflags=nodocs update && \
	yum -y --setopt=tsflags=nodocs install httpd mod_ssl openssl && \
	yum clean all && rm -rf /var/cache/yum
#RUN sed -i 's#UserDir disabled#\#UserDir disabled#g' /etc/httpd/conf.d/userdir.conf && \
#	sed -i 's#\#UserDir public_html#UserDir public_html#g' /etc/httpd/conf.d/userdir.conf

VOLUME	[ "/var/log/httpd" ]

EXPOSE	80 443
