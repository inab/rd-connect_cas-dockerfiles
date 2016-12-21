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

5. Steps to create the containers for Web User Management Interface Application.
	1. First of all we generate the umi_data_container based on centos:7 oficial image:
	
	```bash
	docker create -v /var/log/httpd -v /etc/httpd -v /etc/openldap --name umi_data_container centos:7 /bin/true
	docker cp blblblblblb umi_data_container:/etc/
	```
	
	2. Now we build CentOS Apache Web server image, tagging it locally and based on httpd_rd-connect:

	```bash
	HTTPD_TAG=2.4
	docker build -t rd-connect.eu/httpd:${HTTPD_TAG} httpd_rd-connect
	```
	
	3. We augment it with phpldapadmin:
	
	```bash
	PLA_TAG=latest
	docker build -t rd-connect.eu/phpldapadmin:${PLA_TAG} phpldapadmin_rd-connect
	```
	
	4. Now we build rd-connect.eu/umi the image that will create container to deploy user management interface
	
	```bash
	UMI_TAG=latest
	docker build -t rd-connect.eu/umi:${UMI_TAG} umi_rd-connect
	```
	
	5. Last, we run rd-connect.eu/umi based on rd-connect.eu/umi:${UMI_TAG} image, giving it a name of `rd-connect.eu_umi` and mounting volumes exported by `umi_data_container`
	
	```bash
	docker run -d --volumes-from umi_data_container --name rd-connect.eu_umi rd-connect.eu/umi:${UMI_TAG}
	```
