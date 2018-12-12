FROM	nimmis/centos:7

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	description="Common layout for different RD-Connect CentOS based images" vendor="BSC-CNS" version="7" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

# First, setup the timezone
RUN	rm -f /etc/localtime && \
	ln -s ../usr/share/zoneinfo/Europe/Madrid /etc/localtime

# As we are inheriting from nimmis init system, which could be outdated, we update the system packages first
RUN	yum -y install deltarpm && yum -y update || true && yum -y install bzip2 make sysvinit-tools

ENV	container docker

ARG	LFS_VERSION=8.3
ARG	LFS_BOOTSCRIPTS_URL=http://www.linuxfromscratch.org/lfs/downloads/${LFS_VERSION}/
ARG	BLFS_BOOTSCRIPTS_URL=http://www.linuxfromscratch.org/blfs/downloads/${LFS_VERSION}/

ENV	LFS_BOOTSCRIPTS_VER_PATTERN=lfs-bootscripts-*
ENV	LFS_BOOTSCRIPTS_ARCHIVE_PATTERN=${LFS_BOOTSCRIPTS_VER_PATTERN}.tar.bz2
ENV	LFS_BOOTSCRIPTS_DIR_PATTERN=/tmp/${LFS_BOOTSCRIPTS_VER_PATTERN}

ENV	BLFS_BOOTSCRIPTS_VER_PATTERN=blfs-bootscripts-*
ENV	BLFS_BOOTSCRIPTS_ARCHIVE_PATTERN=${BLFS_BOOTSCRIPTS_VER_PATTERN}.tar.bz2
ENV	BLFS_BOOTSCRIPTS_DIR_PATTERN=/root/${BLFS_BOOTSCRIPTS_VER_PATTERN}

# First, LFS skeleton
RUN	cd /tmp && \
	wget -nv -r -nH -l1 -np -nd -A "${LFS_BOOTSCRIPTS_VER_PATTERN}" "${LFS_BOOTSCRIPTS_URL}" && \
	tar xf ${LFS_BOOTSCRIPTS_ARCHIVE_PATTERN} && \
	rm -f ${LFS_BOOTSCRIPTS_ARCHIVE_PATTERN} && \
	cd ${LFS_BOOTSCRIPTS_DIR_PATTERN} && \
	make install && \
	chmod -x /etc/init.d/* && \
	cd /tmp && \
	rm -rf ${LFS_BOOTSCRIPTS_DIR_PATTERN}
# Then, BLFS templates
RUN	cd /root && \
	wget -nv -r -nH -l1 -np -nd -A "${BLFS_BOOTSCRIPTS_VER_PATTERN}" "${BLFS_BOOTSCRIPTS_URL}" && \
	tar xf ${BLFS_BOOTSCRIPTS_ARCHIVE_PATTERN} && \
	rm -f ${BLFS_BOOTSCRIPTS_ARCHIVE_PATTERN} && \
	ln -s ${BLFS_BOOTSCRIPTS_VER_PATTERN} blfs-bootscripts
# Last, the integration with nimmis init system
ADD	my_initd_service /

#CMD	[ "/usr/sbin/init" ]
