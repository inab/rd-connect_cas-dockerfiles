FROM	rd-connect.eu/httpd:2.4
LABEL	description="RD-Connect User Management Interface prerequisites" vendor="BSC-CNS" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

ARG	NODE_VERSION=4.8.4
ARG	UMI_SERVER=rdconnect-umi.rd-connect.eu

ARG	HTTPD_CERTS_FILE=/tmp/cas-httpd-certs.tar
ARG	HTTPD_CERTS_PROFILE=cas-httpd
ENV	LOCAL_HTTPD_CERTS_DIR=/tmp/rd-connect_umi_certs

# Setting up the CA certificate and server certificates (very important!)
ADD	"${HTTPD_CERTS_FILE}" "${LOCAL_HTTPD_CERTS_DIR}"
ENV	CA_CERT=/etc/openldap/certs/cacert.pem
RUN	mv "${LOCAL_HTTPD_CERTS_DIR}"/cacert.pem "${CA_CERT}"
RUN	sed -i "/TLS_CACERTDIR/a TLS_CACERT ${CA_CERT}" /etc/openldap/ldap.conf

# Allowing accessing the server from outside 127.0.0.1
ENV	UMI_CERT=/etc/pki/tls/certs/${UMI_SERVER}.crt
ENV	UMI_KEY=/etc/pki/tls/private/${UMI_SERVER}.key
RUN	mv "${LOCAL_HTTPD_CERTS_DIR}"/"${HTTPD_CERTS_PROFILE}"/cert.pem "${UMI_CERT}" && \
	mv "${LOCAL_HTTPD_CERTS_DIR}"/"${HTTPD_CERTS_PROFILE}"/key.pem "${UMI_KEY}"
RUN	sed -i "/^#ServerName/a ServerName ${UMI_SERVER}" /etc/httpd/conf/httpd.conf
RUN	sed -i "s#^SSLCertificateFile .*#SSLCertificateFile ${UMI_CERT}#" /etc/httpd/conf.d/ssl.conf && \
	sed -i "s#^SSLCertificateKeyFile .*#SSLCertificateKeyFile ${UMI_KEY}#" /etc/httpd/conf.d/ssl.conf && \
	sed -i "/^#SSLCACertificateFile/a SSLCACertificateFile ${CA_CERT}" /etc/httpd/conf.d/ssl.conf

# UMI prerequisites
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
	make -j 4 && \
	make install && \
	rm -rf /tmp/node-v*

#RUN useradd -ms /bin/bash rdconnect-rest
#RUN	useradd -m -U -c 'RD-Connect REST API unprivileged user' rdconnect-rest
