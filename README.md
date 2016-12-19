RD-Connect CAS / LDAP containers
================================

Some of the next steps depend on described at [README-CA.md](README-CA.md).

Steps to create the containers
--------------------------------

1. Build CentOS common container, tagging it locally:

	```bash
	docker build -t rd-connect.eu/centos:7 centos_rd-connect
	```

2. Build CentOS+OpenJDK common container, tagging it locally:

	```bash
	docker build -t rd-connect.eu/openjdk:7 openjdk_rd-connect
	```

3. Build CentOS Tomcat container (for instance, 7.0.73), tagging it locally:

	```bash
	TOMCAT_TAG=7.0.73
	docker build --build-arg="TOMCAT_TAG=${TOMCAT_TAG}" -t rd-connect.eu/tomcat:${TOMCAT_TAG} -t rd-connect.eu/tomcat:7 tomcat_rd-connect
	```

4. Build RD-Connect OpenLDAP container, along with its images (to be used by CAS):

	```bash
	CAS_TAG=cas-4.1.x
	mkdir -p "${PWD}"/openldap_rd-connect/tmp
	CAS_LDAP_CERTS_FILE=/tmp/cas-ldap-certs.tar
	docker run --volumes-from rd-connect_ca-store rd-connect.eu/rd-connect_ca cas-ldap > "${PWD}"/openldap_rd-connect/"${CAS_LDAP_CERTS_FILE}"
	docker build --build-arg="CAS_LDAP_CERTS_FILE=${CAS_LDAP_CERTS_FILE}" --build-arg="CASBRANCH=${CAS_TAG}" -t rd-connect.eu/cas-ldap:${CAS_TAG} openldap_rd-connect
	rm -f "${PWD}"/openldap_rd-connect/tmp
	```

3. Steps to create the containers for Web User Management Interface Application.
	First of all we generate the umi_data_container based on centos:7 oficial image:
	
	```bash
	$ docker create -v /var/log/httpd /etc/httpd --name umi_data_container centos:7 /bin/true
	```
	
	Now we build CentOS Apache Web server image (for instance, 2.4.6), tagging it locally and based on httpd_rd-connect:

	```bash
	HTTPD_TAG=latest
	docker build -t rd-connect.eu/httpd:${HTTPD_TAG} httpd_rd-connect
	```
	
	Now we run rd-connect.eu/httpd based on rd-connect.eu/httpd:${HTTPD_TAG} image, giving it a name of rd-connect.eu_httpd and mounting volumes exported by umi_data_container
	```bash
	docker run -d --volumes-from umi_data_container --name rd-connect.eu_httpd rd-connect.eu/httpd:${HTTPD_TAG}
	```
	
	Now we build rd-connect.eu/umi the image that will create container to deploy user management interface
	
