FROM	rd-connect.eu/centos:7
MAINTAINER	José María Fernández <jmfernandez@cnio.es>

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	Description="RD-Connect OpenLDAP setup" Vendor="CNIO" Version="1.0"

ARG	CASBRANCH=cas-4.1.x
ENV	CASCLONE=/tmp/ldap-cas-${CASBRANCH}
ARG	CAS_LDAP_CERTS_DIR=/tmp/rd-connect_cas_ldap_certs
ENV	LOCAL_CAS_LDAP_CERTS_DIR=/tmp/rd-connect_cas_ldap_certs

# EPEL is needed for apg program (a password generator)
RUN	yum install -y openldap-servers openldap-clients epel-release git patch
# so it must be installed afterwards
RUN	yum install -y apg
RUN	cp /usr/share/openldap-servers/DB_CONFIG.example /var/lib/ldap/DB_CONFIG
RUN	chown ldap. /var/lib/ldap/DB_CONFIG
RUN	curl -o /tmp/openldap-centos.patch 'https://bugs.centos.org/file_download.php?file_id=3559&type=bug' && \
	( patch -d / -p 0 -N -t --dry-run < /tmp/openldap-centos.patch && \
	patch -d / -p 0 -N -t < /tmp/openldap-centos.patch || true ) && \
	rm -f /tmp/openldap-centos.patch
# This is needed, in order to get next steps working
RUN	systemctl enable slapd
# We fetch this, as it contains the LDAP setup script and schemas
COPY	"${CAS_LDAP_CERTS_DIR}" "${LOCAL_CAS_LDAP_CERTS_DIR}"
RUN	git clone -b "${CASBRANCH}" https://github.com/inab/ldap-rest-cas4-overlay.git "${CASCLONE}" && \
	/bin/bash -x "${CASCLONE}/ldap-schemas/setup-ldap.sh" "${LOCAL_CAS_LDAP_CERTS_DIR}" "/usr/sbin/slapd -u ldap -h 'ldapi:/// ldap:///'" "pkill slapd ; sleep 5" && \
	rm -rf "${CASCLONE}" "${LOCAL_CAS_LDAP_CERTS_DIR}"

# Last, cleanup!!
RUN	yum autoremove -y git patch
RUN	yum clean all

EXPOSE	389 636
VOLUME	[ "/etc/openldap", "/var/lib/ldap" ]
CMD	[ "/usr/sbin/init" ]
