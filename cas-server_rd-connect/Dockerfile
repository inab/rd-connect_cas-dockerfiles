FROM	rd-connect.eu/tomcat:8

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	description="Server setup needed by RD-Connect CAS + CAS Management" vendor="BSC-CNS" version="1.0" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

# Arguments for the build script
ARG	CAS_TAG=cas-5.3.x
ARG	CAS_RELEASE=2a8ab72e9f45c08adb4dc8d908f122f78b52a16b
ARG	CAS_MGMT_RELEASE=6f1da90bb40f6ce8c546d0878fc8f49de6f7568c

# Adding and running the build script
ADD	docker-build.bash /tmp
RUN	/tmp/docker-build.bash "${CAS_TAG}" "${CAS_RELEASE}" "${CAS_MGMT_RELEASE}" && rm -f /tmp/docker-build.bash

# This must be the last (but one) sentence, otherwise we are losing all the setups!!!
EXPOSE	9443
VOLUME	[ "/etc/cas", "/etc/tomcat8", "/var/log/cas" ]

# This entrypoint does the initialization work
ADD	docker-entrypoint.bash	/usr/local/sbin
ENTRYPOINT	[ "/usr/local/sbin/docker-entrypoint.bash" ]
# As we have added an entrypoint, we have to explicitly define a CMD, as it is not inherited
CMD	[ "/my_init" ]
