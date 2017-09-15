FROM	rd-connect.eu/openjdk:8

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	description="Tomcat 7 layout for different RD-Connect CentOS based images" vendor="BSC-CNS" version="7.0.81" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

ARG	TOMCAT_TAG=7.0.81
ENV	TOMCATCLONE=/tmp/tomcat-${TOMCAT_TAG}

# Now, the steps needed to install RD-Connect CAS and CAS-Management
RUN	yum install -y git rpmdevtools

# We fetch this, as it contains the Tomcat building script
RUN	git clone -b "${TOMCAT_TAG}" https://github.com/inab/rpm-tomcat7.git "${TOMCATCLONE}"
RUN	/bin/bash "${TOMCATCLONE}/rpm-generator.sh"
RUN	yum install -y ~/rpmbuild/RPMS/noarch/*.rpm && \
	rm -rf ~/rpmbuild
# Now, creating a symlink from tomcat7 to tomcat in /etc and /usr/share
# so next instructions are coherent
RUN	ln -s tomcat7 /etc/tomcat && \
	ln -s tomcat7 /usr/share/tomcat

# Cleaning up Tomcat build
RUN	rm -rf "${TOMCATCLONE}"

# Last, cleanup rpmdevtools and yum caches!!
RUN	yum autoremove -y rpmdevtools
RUN	yum clean all && rm -rf /var/cache/yum

# And with this, tomcat is initialized on container startup
RUN	echo '[program:tomcat7]' > /etc/supervisord.d/tomcat7.conf && echo 'command=/my_initd_service tomcat7' >> /etc/supervisord.d/tomcat7.conf

VOLUME	[ "/var/log/tomcat7" ]
