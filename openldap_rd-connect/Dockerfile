FROM	rd-connect.eu/centos:7
MAINTAINER	José María Fernández <jmfernandez@cnio.es>

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	Description="RD-Connect OpenLDAP setup" Vendor="CNIO" Version="1.0"

ARG	CAS_RELEASE=6ebf2bc2ecfb1981ff50f0279080123d640f041e
ENV	CASCLONE=/tmp/ldap-cas-${CAS_RELEASE}
ARG	LDAP_CERTS_PROFILE=cas-ldap
ARG	CAS_LDAP_CERTS_FILE=/tmp/cas-ldap-certs.tar
ENV	LOCAL_CAS_LDAP_CERTS_DIR=/tmp/rd-connect_cas_ldap_certs

# This must be done BEFORE, so /etc/sysconfig/slapd file from CentOS is not overwritten
RUN	cd /root/blfs-bootscripts && make install-slapd && rm -f /etc/sysconfig/slapd && sed -i 's#SLAPD_SERVICES#SLAPD_URLS#g' /etc/init.d/slapd
RUN	echo '[program:slapd]' > /etc/supervisord.d/slapd.conf && echo 'command=/my_initd_service slapd' >> /etc/supervisord.d/slapd.conf
# EPEL is needed for apg program (a password generator)
RUN	yum install -y openldap-servers openldap-clients epel-release git patch
# so it must be installed afterwards
RUN	yum install -y apg gnutls-utils
RUN	cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
RUN	chown ldap. /var/lib/ldap/DB_CONFIG
RUN	curl -o /tmp/openldap-centos.patch 'https://bugs.centos.org/file_download.php?file_id=3559&type=bug' && \
	( patch -d / -p 0 -N -t --dry-run < /tmp/openldap-centos.patch && \
	patch -d / -p 0 -N -t < /tmp/openldap-centos.patch || true ) && \
	rm -f /tmp/openldap-centos.patch
# This is needed, in order to get next steps working
# We fetch this, as it contains the LDAP setup script and schemas
ADD	"${CAS_LDAP_CERTS_FILE}" "${LOCAL_CAS_LDAP_CERTS_DIR}"
RUN	git clone https://github.com/inab/ldap-rest-cas4-overlay.git "${CASCLONE}" && \
	cd "${CASCLONE}" && \
	git checkout "${CAS_RELEASE}" && \
	/bin/bash -x "${CASCLONE}/ldap-schemas/setup-ldap.sh" "${LOCAL_CAS_LDAP_CERTS_DIR}" "${LDAP_CERTS_PROFILE}" "/etc/init.d/slapd start" '/etc/init.d/slapd stop' && \
	rm -rf "${CASCLONE}" "${LOCAL_CAS_LDAP_CERTS_DIR}"

# Last, cleanup!!
RUN	yum autoremove -y git patch
RUN	yum clean all

EXPOSE	389 636
VOLUME	[ "/etc/openldap", "/var/lib/ldap", "/var/log" ]
