FROM	rd-connect.eu/rdconnect-umi-prereqs:latest
LABEL	description="RD-Connect User Management Interface" vendor="BSC-CNS" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

#UMI_TAG=latest
#mkdir -p "${PWD}"/umi_rd-connect/tmp


ARG	USERMANAGEMENT_BRANCH=ldap
ARG	USERMANAGEMENT_CHECKOUT=b40c52321c789dbc96430d607bb96d21065428e4

ARG	CAS_SERVER_URL=https://rdconnectcas.rd-connect.eu:9443/cas
ARG	LDAP_SERVER=ldap.rd-connect.eu
ARG	CAS_LDAP_USER="cn=admin,dc=rd-connect,dc=eu"
# This is a placeholder for the true intermediate LDAP admin password
ARG	CAS_LDAP_PASS=changeit

RUN	useradd -m -U -c 'RD-Connect REST API unprivileged user' rdconnect-rest
# Configure apache for application
# User was created in the prerequisites dockerfile
USER	rdconnect-rest
ENV	HOME=/home/rdconnect-rest
WORKDIR	${HOME}

RUN	git clone -b "${USERMANAGEMENT_BRANCH}" https://github.com/inab/rd-connect-user-management.git && \
	cd rd-connect-user-management && \
	git checkout "$USERMANAGEMENT_CHECKOUT"
RUN	cd rd-connect-user-management && ./install-deps.sh
RUN	mkdir -p RDConnect-UserManagement-REST-API
RUN	cd rd-connect-user-management && cp -dpr configs user-management.cgi user-management.fcgi user-management.psgi libs "$HOME"/RDConnect-UserManagement-REST-API && cp template-config.ini "$HOME"/RDConnect-UserManagement-REST-API/configs/user-management.ini
RUN	sed -i "s/^.*ldap_host=.*/ldap_host=${LDAP_SERVER}/; s/^.*ldap_user=.*/ldap_user=${CAS_LDAP_USER}/; s/^.*ldap_pass=.*/ldap_pass=${CAS_LDAP_PASS}/; s#^cas_url=.*#cas_url=${CAS_SERVER_URL}#;" RDConnect-UserManagement-REST-API/configs/user-management.ini

ENV	UMI_CLONE=${HOME}/user-management-interface
ARG	UMI_BRANCH=master
ARG	UMI_CHECKOUT=5023689900ab42f60b73a4a7711f7086c8d91700

RUN	git clone -b "${UMI_BRANCH}" https://github.com/inab/rd-connect-user-management-interface.git "${UMI_CLONE}" && \
	cd "${UMI_CLONE}" && \
	git checkout "${UMI_CHECKOUT}"
WORKDIR ${UMI_CLONE}
RUN	npm install
RUN	PATH="${UMI_CLONE}/node_modules/.bin:$PATH" gulp build && test -f build/js/app.js
RUN	mkdir -p "$HOME/DOCUMENT_ROOT" && cp -dpTr "${UMI_CLONE}"/build "$HOME/DOCUMENT_ROOT/user-management"

RUN	chmod go+rx "$HOME"
# The SELinux part
#RUN	chcon -Rv --type=httpd_sys_content_t "$HOME"/DOCUMENT_ROOT && \
#	chcon -Rv --type=httpd_sys_content_t "$HOME"/rd-connect-user-management && \
#	chcon -Rv --type=httpd_sys_content_t "$HOME"/RDConnect-UserManagement-REST-API && \
#	chcon -Rv --type=httpd_sys_script_exec_t "$HOME"/RDConnect-UserManagement-REST-API/user-management.cgi

# Cleaning up, user level
RUN	rm -rf "${UMI_CLONE}" "${HOME}"/.npm

USER	root
ENV	HOME=/root
WORKDIR	${HOME}

#RUN	yum --enablerepo=epel install -y httpd-itk
#RUN	yum install -y checkpolicy policycoreutils-python && \
#	setsebool -P httpd_enable_cgi=1 && \
#	setsebool -P httpd_read_user_content=1 && \
#	setsebool -P httpd_can_network_connect=1 && \
#	setsebool -P httpd_enable_homedirs=1 && \
#	cd /tmp && \
#	checkmodule -M -m -o rdconnect-user-management.mod /home/rdconnect-rest/rd-connect-user-management/selinux/rdconnect-user-management.te && \
#	semodule_package -o rdconnect-user-management.pp -m rdconnect-user-management.mod && \
#	semodule -i rdconnect-user-management.pp
#RUN	sed -i 's/^#\(LoadModule \)/\1/' /etc/httpd/conf.modules.d/00-mpm-itk.conf
COPY	umi.conf /tmp
RUN	sed -e '/<\/VirtualHost>/r /tmp/umi.conf' -e 'x;$G' -i /etc/httpd/conf.d/ssl.conf && rm /tmp/umi.conf

# Enabling the API as such


# Cleaning up, root level
RUN	yum autoremove -y git
RUN	yum clean all && rm -rf /var/cache/yum

VOLUME	[ "/home/rdconnect-rest/RDConnect-UserManagement-REST-API/configs" ]
