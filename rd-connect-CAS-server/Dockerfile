FROM	rd-connect.eu/tomcat:7
MAINTAINER	José María Fernández <jmfernandez@cnio.es>

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	Description="Server setup needed by RD-Connect CAS + CAS Management + PWM" Vendor="CNIO" Version="1.0"

# Now, the steps needed to install RD-Connect CAS and CAS-Management
RUN	yum install -y git java-devel ant ant-contrib maven apg

ARG	CAS_TAG=cas-4.1.x
ARG	CAS_RELEASE=23b48851c7a2e84ed8c0e413c0f6c87991bc5545
ENV	CASCLONE=/tmp/ldap-cas-${CAS_RELEASE}
ARG	CAS_CERTS_PROFILE=cas-tomcat
ARG	CAS_TOMCAT_CERTS_FILE=/tmp/cas-tomcat-certs.tar
ENV	LOCAL_CAS_TOMCAT_CERTS_DIR=/tmp/rd-connect_cas_tomcat_certs
# This is a placeholder for the true intermediate LDAP admin password
ARG	CAS_LDAP_PASS=changeit

# Checking out CAS
RUN	git clone --recurse-submodules -b "${CAS_TAG}" https://github.com/inab/ldap-rest-cas4-overlay.git "${CASCLONE}" && \
	cd "${CASCLONE}" && \
	git checkout "${CAS_RELEASE}"
# Compiling CAS
RUN	cd "${CASCLONE}" && mvn clean package

ADD	"${CAS_TOMCAT_CERTS_FILE}" "${LOCAL_CAS_TOMCAT_CERTS_DIR}"


# Installing CAS
RUN	/bin/bash -x "${CASCLONE}/etc/setup-tomcat.sh" "${LOCAL_CAS_TOMCAT_CERTS_DIR}" "${CAS_CERTS_PROFILE}" "${CAS_LDAP_PASS}" '/etc/sysconfig/tomcat7'
RUN	chown tomcat: "${CASCLONE}"/target/cas.war && cp -p "${CASCLONE}"/target/cas.war /var/lib/tomcat7/webapps

# Now, CAS Management
ARG	CAS_MGMT_RELEASE=03c0194e38f124335a70814f22ad852cff8abcb2
ENV	CAS_MGMT_CLONE=/tmp/cas4-mgmt-${CAS_MGMT_RELEASE}

# Checking out CAS Management
RUN	git clone --recurse-submodules -b "${CAS_TAG}" https://github.com/inab/cas4-management-overlay.git "${CAS_MGMT_CLONE}" && \
	cd "${CAS_MGMT_CLONE}" && \
	git checkout "${CAS_MGMT_RELEASE}"

# Compiling CAS Management
RUN	cd "${CAS_MGMT_CLONE}" && mvn clean package

# Installing CAS Management
RUN	install -D -o tomcat -g tomcat -m 644 "${CAS_MGMT_CLONE}"/etc/log4j2-cas-management.system.xml /etc/cas/log4j2-cas-management.xml
RUN	chown tomcat: "${CAS_MGMT_CLONE}"/target/cas-management.war && cp -p "${CAS_MGMT_CLONE}"/target/cas-management.war /var/lib/tomcat7/webapps

# Last, cleanup!!
RUN	rm -rf "${CASCLONE}" "${CAS_MGMT_CLONE}" "${LOCAL_CAS_TOMCAT_CERTS_DIR}" ~/.m2
RUN	yum autoremove -y git ant ant-contrib maven apg
RUN	yum clean all

# This must be the last sentence, otherwise we are losing all the setups!!!
EXPOSE	9443
VOLUME	[ "/etc/cas", "/etc/tomcat7", "/var/log/cas" ]
