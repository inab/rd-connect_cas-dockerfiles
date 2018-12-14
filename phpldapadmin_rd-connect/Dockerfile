FROM	rd-connect.eu/httpd:2.4
LABEL	description="PHPLDAPAdmin for RD-Connect" vendor="BSC-CNS" version="7" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

RUN	yum update -y --setopt=tsflags=nodocs && \
	yum install -y --setopt=tsflags=nodocs mod_php && \
	yum install -y --setopt=tsflags=nodocs phpldapadmin && \
	yum clean all && rm -rf /var/cache/yum

VOLUME	[ "/etc/phpldapadmin", "/etc/openldap", "/etc/pki/tls" ]

# This entrypoint does the initialization work
ADD	docker-entrypoint.bash	/usr/local/sbin
ENTRYPOINT	[ "/usr/local/sbin/docker-entrypoint.bash" ]
# As we have added an entrypoint, we have to explicitly define a CMD, as it is not inherited
CMD	[ "/my_init" ]
