 #!/bin/bash

set -e

TGCBRANCH=json-web-key-generator-0.3

if [ $# -ge 3 ] ; then
	CAS_TAG="$1"
	CAS_RELEASE="$2"
	CAS_MGMT_RELEASE="$3"

	# Now, the prerequisites needed to install RD-Connect CAS and CAS-Management
	yum install -y git java-devel ant ant-contrib apg redis
	
	CASCLONE=/tmp/cas-repo
	TGCCLONE=/tmp/tgc-repo
	
	# Checking out CAS
	git clone -b "${CAS_TAG}" https://github.com/inab/rd-connect-cas-overlay.git "${CASCLONE}"
	cd "${CASCLONE}"
	git checkout "${CAS_RELEASE}"
	# Compiling CAS
	./mvnw -B -T 1C clean package
	
	# Compiling TGC (for CAS install script)
	git clone -b "${TGCBRANCH}" https://github.com/mitreid-connect/json-web-key-generator.git "${TGCCLONE}"
	cd "${TGCCLONE}"
	# As the repo does not contain the Maven wrapper, copy it from CAS repo
	cp -dpr "${CASCLONE}"/{mvnw,maven} .
	./mvnw -B -T 1C clean package

	# Installing CAS
	chown tomcat: "${CASCLONE}"/target/cas.war && cp -p "${CASCLONE}"/target/cas.war /var/lib/tomcat8/webapps
	mkdir -p /etc/cas && chown tomcat: /etc/cas

	# Now, CAS Management
	CAS_MGMT_CLONE=/tmp/cas-mgmt-repo

	# Checking out CAS Management
	git clone --recurse-submodules -b "${CAS_TAG}" https://github.com/inab/rd-connect-cas-management-overlay.git "${CAS_MGMT_CLONE}"
	cd "${CAS_MGMT_CLONE}"
	git checkout "${CAS_MGMT_RELEASE}"

	# Compiling CAS Management
	./mvnw -B -T 1C clean package

	# Installing CAS Management
	chown tomcat: "${CAS_MGMT_CLONE}"/target/cas-management.war
	cp -p "${CAS_MGMT_CLONE}"/target/cas-management.war /var/lib/tomcat8/webapps


##### And now, PWM
##### http://www.serveradventures.com/the-adventures/installing-pwm-open-source-password-self-service-in-2016
####ARG	PWM_RELEASE=2bf5f8333e9cabfc89b0912424b2401e7795a9cf
####ENV	PWM_CLONE=/tmp/pwm-${PWM_RELEASE}
####
####ARG	PWM_APPLICATION_PATH=/var/lib/pwm
####RUN	git clone --recurse-submodules https://github.com/pwm-project/pwm.git "${PWM_CLONE}" && \
####	cd "${PWM_CLONE}" && \
####	git checkout "${PWM_CLONE}"
####
##### Basic PWM setup before compilation
####RUN	install -D -o tomcat -g tomcat -m 755 -d "${PWM_APPLICATION_PATH}" && \
####	sed -i "s#>unspecified<#>${PWM_APPLICATION_PATH}<#" "${PWM_CLONE}"/server/src/main/webapp/WEB-INF/web.xml
####
##### Compiling PWM
####RUN	cd "${PWM_CLONE}" && PATH="$MAVEN_HOME/bin:$PATH" mvn -B clean package
####
##### Installing PWM
####RUN	chown tomcat: "${PWM_CLONE}"/server/target/pwm-*.war && cp -p "${PWM_CLONE}"/server/target/pwm-*.war /var/lib/tomcat8/webapps/pwm.war


	# Last, cleanup!!
	# We cannot remove the CAS checked out repository, as it must be used in the first use
	for repo in "${CASCLONE}" "${CAS_MGMT_CLONE}" ; do
		cd "$repo" && ./mvnw -B clean
	done
	rm -rf /tmp/phantomjs /tmp/npm* ~/.m2 ~/.npm
	yum autoremove -y git ant ant-contrib
	yum clean all && rm -rf /var/cache/yum

	# There is a bug in Docker 1.12, where inherited volumes sometimes do not get the proper permissions
	chown -R tomcat: /etc/tomcat8
else
	echo "ERROR: Incorrect number of parameters" 1>&2
	exit 1
fi
