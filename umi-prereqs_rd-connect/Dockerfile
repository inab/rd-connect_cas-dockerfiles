FROM	rd-connect.eu/phpldapadmin:latest
MAINTAINER	Andrés Cañada Pallarés <acanada@cnio.es>, José María Fernández <jmfernandez@cnio.es>
LABEL	Description="RD-Connect User Management Interface prerequisites" Vendor="CNIO"

ARG	NODE_VERSION=4.8.0

RUN	yum update -y --setopt=tsflags=nodocs
RUN	yum install -y --setopt=tsflags=nodocs gcc gcc-c++ automake flex \
	bison make patch perl perl-devel perl-CPAN perl-Net-IDN-Encode \
	perl-IO-Compress perl-Net-SSLeay perl-Crypt-SSLeay perl-XML-LibXML
RUN	yum install -y --setopt=tsflags=nodocs epel-release git
RUN	yum install -y --enablerepo=epel --setopt=tsflags=nodocs apg

RUN 	cd /tmp && \
	wget -nv https://nodejs.org/download/release/v${NODE_VERSION}/node-v${NODE_VERSION}.tar.xz && \
	tar xf node-v${NODE_VERSION}.tar.xz && \
	cd node-v${NODE_VERSION} && \
	./configure && \
	make && \
	make install && \
	rm -rf /tmp/node-v*

#RUN useradd -ms /bin/bash rdconnect-rest
RUN	useradd -m -U -c 'RD-Connect REST API unprivileged user' rdconnect-rest
