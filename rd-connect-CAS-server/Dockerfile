FROM	rd-connect.eu/tomcat:7

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	description="Server setup needed by RD-Connect CAS + CAS Management + PWM" vendor="BSC-CNS" version="1.0" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

# Now, the prerequisites needed to install RD-Connect CAS, CAS-Management and PWM
RUN	yum install -y git java-devel ant ant-contrib apg

ARG	MAVEN_VERSION=3.3.9
ENV	MAVEN_HOME=/tmp/apache-maven-${MAVEN_VERSION}
RUN	cd /tmp && \
	curl -O https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
	tar xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz

ARG	CAS_TAG=cas-4.1.x
ARG	CAS_RELEASE=e8f756dc805919f1450f6f6c40bbe72498485a62
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
RUN	cd "${CASCLONE}" && PATH="$MAVEN_HOME/bin:$PATH" mvn clean package

ADD	"${CAS_TOMCAT_CERTS_FILE}" "${LOCAL_CAS_TOMCAT_CERTS_DIR}"


# Installing CAS
RUN	PATH="$MAVEN_HOME/bin:$PATH" /bin/bash -x "${CASCLONE}/etc/setup-tomcat.sh" "${LOCAL_CAS_TOMCAT_CERTS_DIR}" "${CAS_CERTS_PROFILE}" "${CAS_LDAP_PASS}" '/etc/sysconfig/tomcat7'
RUN	chown tomcat: "${CASCLONE}"/target/cas.war && cp -p "${CASCLONE}"/target/cas.war /var/lib/tomcat7/webapps

# Now, CAS Management
ARG	CAS_MGMT_RELEASE=03c0194e38f124335a70814f22ad852cff8abcb2
ENV	CAS_MGMT_CLONE=/tmp/cas4-mgmt-${CAS_MGMT_RELEASE}

# Checking out CAS Management
RUN	git clone --recurse-submodules -b "${CAS_TAG}" https://github.com/inab/cas4-management-overlay.git "${CAS_MGMT_CLONE}" && \
	cd "${CAS_MGMT_CLONE}" && \
	git checkout "${CAS_MGMT_RELEASE}"

# Compiling CAS Management
RUN	cd "${CAS_MGMT_CLONE}" && PATH="$MAVEN_HOME/bin:$PATH" mvn clean package

# Installing CAS Management
RUN	install -D -o tomcat -g tomcat -m 644 "${CAS_MGMT_CLONE}"/etc/log4j2-cas-management.system.xml /etc/cas/log4j2-cas-management.xml
RUN	chown tomcat: "${CAS_MGMT_CLONE}"/target/cas-management.war && cp -p "${CAS_MGMT_CLONE}"/target/cas-management.war /var/lib/tomcat7/webapps


# And now, PWM
# http://www.serveradventures.com/the-adventures/installing-pwm-open-source-password-self-service-in-2016
ARG	PWM_RELEASE=2bf5f8333e9cabfc89b0912424b2401e7795a9cf
ENV	PWM_CLONE=/tmp/pwm-${PWM_RELEASE}

ARG	PWM_APPLICATION_PATH=/var/lib/pwm
RUN	git clone --recurse-submodules https://github.com/pwm-project/pwm.git "${PWM_CLONE}" && \
	cd "${PWM_CLONE}" && \
	git checkout "${PWM_CLONE}"

# Basic PWM setup before compilation
RUN	install -D -o tomcat -g tomcat -m 755 -d "${PWM_APPLICATION_PATH}" && \
	sed -i "s#>unspecified<#>${PWM_APPLICATION_PATH}<#" "${PWM_CLONE}"/server/src/main/webapp/WEB-INF/web.xml

# Compiling PWM
RUN	cd "${PWM_CLONE}" && PATH="$MAVEN_HOME/bin:$PATH" mvn clean package

# Installing PWM
RUN	chown tomcat: "${PWM_CLONE}"/server/target/pwm-*.war && cp -p "${PWM_CLONE}"/server/target/pwm-*.war /var/lib/tomcat7/webapps/pwm.war


# Last, cleanup!!
RUN	rm -rf "${MAVEN_HOME}"* /tmp/phantomjs /tmp/npm* ~/.m2 ~/.npm
RUN	rm -rf "${CASCLONE}" "${CAS_MGMT_CLONE}" "${PWM_CLONE}" "${LOCAL_CAS_TOMCAT_CERTS_DIR}"
RUN	yum autoremove -y git ant ant-contrib apg
RUN	yum clean all

# There is a bug in Docker 1.12, where inherited volumes sometimes do not get the proper permissions
RUN	chown -R tomcat: /etc/tomcat7

# This must be the last sentence, otherwise we are losing all the setups!!!
EXPOSE	9443
VOLUME	[ "/etc/cas", "/etc/tomcat7", "/var/lib/pwm", "/var/log/cas" ]
