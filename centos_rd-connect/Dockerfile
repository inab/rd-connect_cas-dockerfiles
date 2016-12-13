FROM	nimmis/centos:7
MAINTAINER	José María Fernández <jmfernandez@cnio.es>

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	Description="Common layout for different RD-Connect CentOS based images" Vendor="CNIO" Version="7"

# First, setup the timezone
RUN	rm -f /etc/localtime && \
	ln -s ../usr/share/zoneinfo/Europe/Madrid /etc/localtime

# As we are inheriting from nimmis init system, which could be outdated, we update the system packages first
RUN	yum -y update || true
RUN	yum -y install bzip2 make sysvinit-tools
ENV	container docker

ARG	LFS_BOOTSCRIPTS_VERSION=20150222
ARG	LFS_BOOTSCRIPTS_URL=http://www.linuxfromscratch.org/lfs/downloads/stable/lfs-bootscripts-${LFS_BOOTSCRIPTS_VERSION}.tar.bz2
ARG	BLFS_BOOTSCRIPTS_VERSION=20160902
ARG	BLFS_BOOTSCRIPTS_URL=http://anduin.linuxfromscratch.org/BLFS/blfs-bootscripts/blfs-bootscripts-${BLFS_BOOTSCRIPTS_VERSION}.tar.xz
RUN	cd /tmp && wget "${LFS_BOOTSCRIPTS_URL}" && tar xf $(basename "${LFS_BOOTSCRIPTS_URL}") && cd "lfs-bootscripts-${LFS_BOOTSCRIPTS_VERSION}" && make install && chmod -x /etc/init.d/*
RUN	cd /root && wget "${BLFS_BOOTSCRIPTS_URL}" && tar xf $(basename "${BLFS_BOOTSCRIPTS_URL}") && ln -s blfs-bootscripts-${BLFS_BOOTSCRIPTS_VERSION} blfs-bootscripts

#CMD	[ "/usr/sbin/init" ]
