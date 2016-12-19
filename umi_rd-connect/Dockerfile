#UMI_TAG=latest
#mkdir -p "${PWD}"/umi_rd-connect/tmp

FROM rd-connect.eu/httpd:latest
MAINTAINER Andrés Cañada Pallarés

ENV NODE_ENV=production
ENV NODE_VERSION=4.7.0
ARG UMIBRANCH=latest
ENV	UMI_CLONE=/home/rdconnect-rest/user-management-interface

RUN yum install -y gcc gcc-c++ && \
	cd /tmp && \
	wget https://nodejs.org/download/release/node-v${NODE_VERSION}.tar.xz && \
	tar xf node-v${NODE_VERSION}.tar.xz && \
	cd node-v${NODE_VERSION} && \
	./configure && \
	make && \
	make install && \
	rm -rf /tmp/node-v*

RUN useradd -ms /bin/bash rdconnect-rest
#Configure apache for application
USER rdconnect-rest
WORKDIR $UMI_CLONE

RUN git clone https://github.com/inab/rd-connect-user-management-interface.git $UMI_CLONE
RUN	yum autoremove -y git
RUN	yum clean all
RUN npm install
ENV PATH="${PWD}/node_modules/.bin:$PATH"

RUN gulp build
RUN mkdir -p "${HOME}/DOCUMENT_ROOT" && cp -dpTr build "${HOME}/DOCUMENT_ROOT/user-management"

EXPOSE 80
VOLUME	[ "/var/log/httpd", "/etc/httpd" ]
