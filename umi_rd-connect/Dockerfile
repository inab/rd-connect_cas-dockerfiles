FROM	rd-connect.eu/httpd:2.4
LABEL	description="RD-Connect User Management Interface" vendor="BSC-CNS" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

# Arguments for the build script
ARG	USERMANAGEMENT_CHECKOUT=477fab8c1ff4ea3d0a84b1f7e282c5071b5dec64
ARG	UMI_CHECKOUT=767a49c3b074f18dcfdb17d93f9ee2fe1e7deec1
ARG	REQS_UI_CHECKOUT=ce168c557b7826a2f0c18e3a7754bf391359936f

# Adding and running the build script
ADD	docker-build.bash docker-umi-build.bash umi.conf /tmp/
RUN	/tmp/docker-build.bash "${USERMANAGEMENT_CHECKOUT}" "${UMI_CHECKOUT}" "${REQS_UI_CHECKOUT}" && \
	rm -f /tmp/docker-build.bash /tmp/docker-umi-build.bash

VOLUME	[ "/home/rdconnect-rest/RDConnect-UserManagement-REST-API/configs" ]

# This entrypoint does the initialization work
ADD	docker-entrypoint.bash	/usr/local/sbin
ENTRYPOINT	[ "/usr/local/sbin/docker-entrypoint.bash" ]
# As we have added an entrypoint, we have to explicitly define a CMD, as it is not inherited
CMD	[ "/my_init" ]
