FROM	alpine:3.8

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	description="RD-Connect commmon key generator" vendor="BSC-CNS" version="0.4" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

ENV	RDCONNECT_KEYSTORE_DIR=/etc/rd-connect_keystore
ENV	RDCONNECT_CASOFT_DIR_REL=rd-connect_ca
ENV	RDCONNECT_CASOFT_DIR=/usr/local/${RDCONNECT_CASOFT_DIR_REL}
ENV	RDCONNECT_CERTS_OUT_DIR=/tmp/rd-connect_certs
# Now, the steps needed to install certtool
# We need these utilities for the packaged script
# Last, cleanup!
COPY	ca_server.conf	/etc/lighttpd/
RUN	apk add --update gnutls-utils openssl bash lighttpd && \
	rm -rf /var/cache/apk/* && \
	echo 'include "ca_server.conf"' >> /etc/lighttpd/lighttpd.conf && \
	mkdir -p "${RDCONNECT_KEYSTORE_DIR}" && \
	chown lighttpd: "${RDCONNECT_KEYSTORE_DIR}" && \
	chmod go= "${RDCONNECT_KEYSTORE_DIR}"
VOLUME	[ "${RDCONNECT_KEYSTORE_DIR}" ]

EXPOSE	80
ENTRYPOINT	[ "su","-","lighttpd","-c","/usr/local/rd-connect_ca/rd-connect_getcert.bash" ]

# This is the last, as previous steps are more or less constant
COPY	"${RDCONNECT_CASOFT_DIR_REL}" "${RDCONNECT_CASOFT_DIR}"
