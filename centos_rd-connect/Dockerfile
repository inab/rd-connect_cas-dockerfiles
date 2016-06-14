FROM	centos:7
MAINTAINER	José María Fernández <jmfernandez@cnio.es>

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	Description="Common layout for different RD-Connect CentOS based images" Vendor="CNIO" Version="7"

# First, setup the timezone
RUN	rm -f /etc/localtime && \
	ln -s ../usr/share/zoneinfo/Europe/Madrid /etc/localtime

# Second, enable systemd (based on https://hub.docker.com/_/centos/)
ENV	container docker
RUN	(cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done) && \
	rm -f /lib/systemd/system/multi-user.target.wants/* && \
	rm -f /etc/systemd/system/*.wants/* && \
	rm -f /lib/systemd/system/local-fs.target.wants/* && \
	rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
	rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
	rm -f /lib/systemd/system/basic.target.wants/* && \
	rm -f /lib/systemd/system/anaconda.target.wants/*
VOLUME	[ "/sys/fs/cgroup" , "/var/log" ]
CMD	[ "/usr/sbin/init" ]
