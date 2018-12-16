FROM	rd-connect.eu/centos:7

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	description="RD-Connect OpenLDAP setup" vendor="BSC-CNS" version="1.1" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

# This must be done BEFORE, so /etc/sysconfig/slapd file from CentOS is not overwritten
RUN	cd /root/blfs-bootscripts && make install-slapd && rm -f /etc/sysconfig/slapd && sed -i 's#SLAPD_SERVICES#SLAPD_URLS#g' /etc/init.d/slapd
RUN	echo '[program:slapd]' > /etc/supervisord.d/slapd.conf && echo 'command=/my_initd_service slapd' >> /etc/supervisord.d/slapd.conf
# EPEL is needed for apg program (a password generator)
# and redis-cli (to store the credentials in the initialization broker)
# so it must be installed afterwards
RUN	yum install -y openldap-servers openldap-clients epel-release git patch && \
	yum install -y apg gnutls-utils redis
#RUN	cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG && \
#	chown ldap. /var/lib/ldap/DB_CONFIG
RUN	curl -o /tmp/openldap-centos.patch 'https://bugs.centos.org/file_download.php?file_id=3559&type=bug' && \
	( patch -d / -p 0 -N -t --dry-run < /tmp/openldap-centos.patch && \
	patch -d / -p 0 -N -t < /tmp/openldap-centos.patch || true ) && \
	rm -f /tmp/openldap-centos.patch

# This is needed, in order to get runtime setup working
ARG	CAS_RELEASE=45bcffc9c4767abbef42c1400f657e820a9663cd
ENV	CASCLONE=/tmp/ldap-cas-${CAS_RELEASE}

RUN	git clone https://github.com/inab/rd-connect-cas-overlay.git "${CASCLONE}" && \
	cd "${CASCLONE}" && \
	git checkout "${CAS_RELEASE}"
# Last, cleanup!!
RUN	yum autoremove -y git patch && \
	yum clean all && rm -rf /var/cache/yum

EXPOSE	389 636
VOLUME	[ "/etc/openldap", "/var/lib/ldap", "/var/log" ]

# This entrypoint does the initialization work
ADD	docker-entrypoint.bash	/usr/local/sbin
ENTRYPOINT	[ "/usr/local/sbin/docker-entrypoint.bash" ]
# As we have added an entrypoint, we have to explicitly define a CMD, as it is not inherited
CMD	[ "/my_init" ]
