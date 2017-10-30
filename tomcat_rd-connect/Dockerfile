FROM	rd-connect.eu/openjdk:8

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	description="Tomcat 8 layout for different RD-Connect CentOS based images" vendor="BSC-CNS" version="8.5.23" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

ARG	TOMCAT_TAG=8.5.23
ENV	TOMCATCLONE=/tmp/tomcat-${TOMCAT_TAG}

# Now, the steps needed to install RD-Connect CAS and CAS-Management
RUN	yum install -y git rpmdevtools

# We fetch this, as it contains the Tomcat building script
RUN	git clone -b "${TOMCAT_TAG}" https://github.com/inab/rpm-tomcat.git "${TOMCATCLONE}"
RUN	/bin/bash "${TOMCATCLONE}/rpm-generator.sh"
RUN	yum install -y ~/rpmbuild/RPMS/noarch/*.rpm && \
	rm -rf ~/rpmbuild
# Now, creating a symlink from tomcat8 to tomcat in /etc and /usr/share
# so next instructions are coherent
RUN	ln -s tomcat8 /etc/tomcat && \
	ln -s tomcat8 /usr/share/tomcat

# Cleaning up Tomcat build
RUN	rm -rf "${TOMCATCLONE}"

# Last, cleanup rpmdevtools and yum caches!!
RUN	yum autoremove -y rpmdevtools
RUN	yum clean all && rm -rf /var/cache/yum

# And with this, tomcat is initialized on container startup
RUN	echo '[program:tomcat8]' > /etc/supervisord.d/tomcat8.conf && echo 'command=/my_initd_service tomcat8' >> /etc/supervisord.d/tomcat8.conf

VOLUME	[ "/var/log/tomcat8" ]
