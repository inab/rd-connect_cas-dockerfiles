FROM	rd-connect.eu/centos:7
MAINTAINER	José María Fernández <jmfernandez@cnio.es>

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	Description="RD-Connect commmon key generator" Vendor="CNIO" Version="0.3"

ENV	RDCONNECT_KEYSTORE_DIR=/etc/rd-connect_keystore
ENV	RDCONNECT_CASOFT_DIR_REL=rd-connect_ca
ENV	RDCONNECT_CASOFT_DIR=/usr/local/${RDCONNECT_CASOFT_DIR_REL}
ENV	RDCONNECT_CERTS_OUT_DIR=/tmp/rd-connect_certs
# Now, the steps needed to install certtool
# We need these utilities for the packaged script
RUN	yum install -y gnutls-utils
# Last, cleanup!
RUN	yum clean all

VOLUME	"${RDCONNECT_KEYSTORE_DIR}"
ENTRYPOINT	[ "/usr/local/rd-connect_ca/rd-connect_getcert.bash" ]

# This is the last, as previous steps are more or less constant
COPY	"${RDCONNECT_CASOFT_DIR_REL}" "${RDCONNECT_CASOFT_DIR}"
