FROM	rd-connect.eu/tomcat:8

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	description="Server setup needed by RD-Connect CAS + CAS Management" vendor="BSC-CNS" version="1.0" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

# Arguments for the build script
ARG	CAS_TAG=cas-4.1.x
ARG	CAS_RELEASE=45bcffc9c4767abbef42c1400f657e820a9663cd
ARG	CAS_MGMT_RELEASE=c477050b237e9eb1e7644e2cf381ebdc20513a7d

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
