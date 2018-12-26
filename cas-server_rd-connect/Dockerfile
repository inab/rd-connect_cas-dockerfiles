FROM	rd-connect.eu/tomcat:8

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	description="Server setup needed by RD-Connect CAS + CAS Management" vendor="BSC-CNS" version="1.0" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

# Arguments for the build script
ARG	CAS_TAG=cas-5.3.x
ARG	CAS_RELEASE=23e78beca87e920716c511f154b5a4844a3b9786
ARG	CAS_MGMT_RELEASE=5ea90f604ea23894519daafb91c249bfef4f156f

# Adding and running the build script
ADD	docker-build.bash /tmp
RUN	/tmp/docker-build.bash "${CAS_TAG}" "${CAS_RELEASE}" "${CAS_MGMT_RELEASE}" && rm -f /tmp/docker-build.bash

# This must be the last (but one) sentence, otherwise we are losing all the setups!!!
EXPOSE	9443
VOLUME	[ "/etc/cas", "/etc/tomcat8", "/var/log/cas" ]

# This is only needed to ease the debugging
RUN	for d in manager host-manager ; do \
		sed -i 's#allow="127#allow="\\d+#' "/var/lib/tomcat8/webapps/${d}/META-INF/context.xml" ; \
	done

# This entrypoint does the initialization work
ADD	docker-entrypoint.bash	/usr/local/sbin
RUN	mv /etc/supervisord.d/tomcat8* /root
#ENTRYPOINT	[ "/usr/local/sbin/docker-entrypoint.bash" ]
# As we have added an entrypoint, we have to explicitly define a CMD, as it is not inherited
#CMD	[ "/my_init" ]
