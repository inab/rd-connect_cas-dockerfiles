FROM	rd-connect.eu/phpldapadmin:latest
MAINTAINER	Andrés Cañada Pallarés <acanada@cnio.es>, José María Fernández <jmfernandez@cnio.es>
LABEL	Description="RD-Connect User Management Interface" Vendor="CNIO"

#UMI_TAG=latest
#mkdir -p "${PWD}"/umi_rd-connect/tmp


ENV NODE_ENV=production
ENV NODE_VERSION=4.7.0
ARG UMIBRANCH=latest

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
#Configure apache for application

USER	rdconnect-rest
ENV	HOME=/home/rdconnect-rest
WORKDIR	${HOME}

ARG	USERMANAGEMENT_CHECKOUT=44422b6e420bfa2d59581cce945a4f40bdb27e7c
RUN	git clone https://github.com/inab/rd-connect-user-management.git && \
	cd rd-connect-user-management && \
	git checkout "$USERMANAGEMENT_CHECKOUT"
RUN	cd rd-connect-user-management && ./install-deps.sh
RUN	mkdir -p RDConnect-UserManagement-REST-API
RUN	cp -dpr user-management.ini user-management.cgi user-management.fcgi user-management.psgi libs "$HOME"/RDConnect-UserManagement-REST-API

ENV	UMI_CLONE=${HOME}/user-management-interface
WORKDIR ${UMI_CLONE}

RUN	git clone https://github.com/inab/rd-connect-user-management-interface.git $UMI_CLONE
RUN	npm install
RUN	PATH="$PWD/node_modules/.bin:$PATH" gulp build
RUN	mkdir -p "$HOME/DOCUMENT_ROOT" && cp -dpTr build "$HOME/DOCUMENT_ROOT/user-management"

# The SELinux part
RUN	chmod go+rx "$HOME" && \
	chcon -Rv --type=httpd_sys_content_t "$HOME"/DOCUMENT_ROOT && \
	chcon -Rv --type=httpd_sys_content_t "$HOME"/rd-connect-user-management && \
	chcon -Rv --type=httpd_sys_content_t "$HOME"/RDConnect-UserManagement-REST-API && \
	chcon -Rv --type=httpd_sys_script_exec_t "$HOME"/RDConnect-UserManagement-REST-API/user-management.cgi

USER	root
ENV	HOME=/root
WORKDIR	${HOME}

RUN	yum --enablerepo=epel install -y httpd-itk
RUN	yum install -y checkpolicy policycoreutils-python && \
	setsebool -P httpd_enable_cgi=1 && \
	setsebool -P httpd_read_user_content=1 && \
	setsebool -P httpd_can_network_connect=1 && \
	setsebool -P httpd_enable_homedirs=1 && \
	cd /tmp && \
	checkmodule -M -m -o rdconnect-user-management.mod /home/rdconnect-rest/rd-connect-user-management/selinux/rdconnect-user-management.te && \
	semodule_package -o rdconnect-user-management.pp -m rdconnect-user-management.mod && \
	semodule -i rdconnect-user-management.pp
RUN	sed -i 's/^#\(LoadModule \)/\1/' /etc/httpd/conf.modules.d/00-mpm-itk.conf

# Cleaning up
RUN	yum autoremove -y git
RUN	yum clean all

EXPOSE 80 443
VOLUME	[ "/var/log/httpd", "/etc/httpd", "/home/rdconnect-rest/RDConnect-UserManagement-REST-API/user-management.ini" ]
