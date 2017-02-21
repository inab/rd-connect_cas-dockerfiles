FROM	rd-connect.eu/tomcat:7
MAINTAINER	José María Fernández <jmfernandez@cnio.es>

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	Description="Server setup needed by RD-Connect CAS + CAS Management + PWM" Vendor="CNIO" Version="1.0"

# Now, the steps needed to install RD-Connect CAS and CAS-Management
RUN	yum install -y git java-devel ant ant-contrib maven apg

ARG	CAS_TAG=cas-4.1.x
ARG	CAS_RELEASE=fce87cac5d496c49273a8deb31570736941cc65a
ENV	CASCLONE=/tmp/ldap-cas-${CAS_RELEASE}
ARG	CAS_CERTS_PROFILE=cas-tomcat
ARG	CAS_TOMCAT_CERTS_FILE=/tmp/cas-tomcat-certs.tar
ENV	LOCAL_CAS_TOMCAT_CERTS_DIR=/tmp/rd-connect_cas_tomcat_certs
ARG	CAS_LDAP_PASS=changeit

# Checking out CAS
RUN	git clone --recurse-submodules -b "${CAS_TAG}" https://github.com/inab/ldap-rest-cas4-overlay.git "${CASCLONE}" && \
	cd "${CASCLONE}" && \
	git checkout "${CAS_RELEASE}"
# Compiling CAS
RUN	cd "${CASCLONE}" && mvn clean package

ADD	"${CAS_TOMCAT_CERTS_FILE}" "${LOCAL_CAS_TOMCAT_CERTS_DIR}"


# Installing 
RUN	/bin/bash -x "${CASCLONE}/etc/setup-tomcat.sh" "${LOCAL_CAS_TOMCAT_CERTS_DIR}" "${CAS_CERTS_PROFILE}" "${CAS_LDAP_PASS}" "/etc/init.d/tomcat7 start" '/etc/init.d/tomcat7 stop' && \
	rm -rf "${CASCLONE}" "${LOCAL_CAS_TOMCAT_CERTS_DIR}"

# Last, cleanup!!
RUN	rm -rf "${CASCLONE}" ~/.m2
#RUN	yum autoremove -y rpmdevtools git ant ant-contrib maven apg epel-release
RUN	yum clean all

# This must be the last sentence, otherwise we are losing all the setups!!!
VOLUME	[ "/etc/cas", "/etc/tomcat7", "/var/log/cas" ]
