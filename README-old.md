Steps to create the containers by hand (using data containers)
----------------------------------

Some of the next steps depend on described at [README-CA.md](README-CA.md).


1. Build CentOS and OpenJDK common containers, tagging it locally:

	```bash
	docker build -t rd-connect.eu/centos:7 centos_rd-connect
	docker build -t rd-connect.eu/openjdk:8 openjdk_rd-connect
	```
2. Build RD-Connect OpenLDAP container, along with its images (to be used by CAS):

	1. If we do not have already one, we generate the ldap_data_container based on centos:7 oficial image:
	
	```bash
	docker create -v /etc/openldap -v /var/lib/ldap -v /var/log --name ldap_data_container centos:7 /bin/true
	```
	
	2. Get the encryption keys for the OpenLDAP image:
	
	```bash
	CAS_TAG=cas-4.1.x
	CAS_LDAP_CERTS_FILE=/tmp/cas-ldap-certs.tar
	LDAP_CERTS_PROFILE=cas-ldap
	mkdir -p "${PWD}"/openldap_rd-connect/tmp
	docker run --rm -v rd-connect_ca-vol:/etc/rd-connect_keystore rd-connect.eu/rd-connect_ca "${LDAP_CERTS_PROFILE}" > "${PWD}"/openldap_rd-connect/"${CAS_LDAP_CERTS_FILE}"
	```
	
	3. Build RD-Connect OpenLDAP container:
	
	```bash
	docker build --build-arg="LDAP_CERTS_PROFILE=${LDAP_CERTS_PROFILE}" --build-arg="CAS_LDAP_CERTS_FILE=${CAS_LDAP_CERTS_FILE}" -t rd-connect.eu/cas-ldap:${CAS_TAG} openldap_rd-connect
	rm -fr "${PWD}"/openldap_rd-connect/tmp
	```
3. Build RD-Connect CAS container, tagging it locally:
	1. Generate the certificates bundle to be used by RD-Connect CAS Tomcat:
	```bash
	CAS_TOMCAT_CERTS_FILE=/tmp/cas-tomcat-certs.tar
	CAS_CERTS_PROFILE=cas-tomcat
	mkdir -p "${PWD}"/rd-connect-CAS-server/tmp
	docker run --rm -v rd-connect_ca-vol:/etc/rd-connect_keystore rd-connect.eu/rd-connect_ca "${CAS_CERTS_PROFILE}" > "${PWD}"/rd-connect-CAS-server/"${CAS_TOMCAT_CERTS_FILE}"
	```
	
	2. Build the tomcat image, and generate the cas_tomcat_data_container based on centos:7 oficial image:
	
	```bash
	TOMCAT_TAG=7.0.75
	docker build --build-arg="TOMCAT_TAG=${TOMCAT_TAG}" -t rd-connect.eu/tomcat:${TOMCAT_TAG} -t rd-connect.eu/tomcat:7 tomcat_rd-connect
	docker create -v /var/log -v /etc/cas -v /etc/tomcat7 --name cas_tomcat_data_container centos:7 /bin/true
	```
	
	3. Extract the LDAP admin password from RD-Connect OpenLDAP container
	
	```bash
	CAS_LDAP_PASS="$(docker run -i -t --rm rd-connect.eu/cas-ldap:cas-4.1.x grep '^domainPass' /etc/openldap/for_sysadmin.txt | cut -f 2 -d =)"
	```
	
	4. Build RD-Connect CAS container:

	```bash
	docker build --build-arg="CAS_CERTS_PROFILE=${CAS_CERTS_PROFILE}" --build-arg="CAS_TOMCAT_CERTS_FILE=${CAS_TOMCAT_CERTS_FILE}" --build-arg="CAS_LDAP_PASS=${CAS_LDAP_PASS}" --build-arg="CAS_RELEASE=${CAS_TAG}" -t rd-connect.eu/rdconnect_cas:${CAS_TAG} rd-connect-CAS-server
	rm -fr "${PWD}"/rd-connect-CAS-server/tmp
	```


5. Steps to create the containers for Web User Management Interface Application.
	1. Generate the certificates bundle to be used by RD-Connect User Management Interface:
	```bash
	mkdir -p "${PWD}"/phpldapadmin_rd-connect/tmp
	HTTPD_CERTS_FILE=/tmp/cas-httpd-certs.tar
	HTTPD_CERTS_PROFILE=cas-httpd
	docker run --rm -v rd-connect_ca-vol:/etc/rd-connect_keystore rd-connect.eu/rd-connect_ca "${HTTPD_CERTS_PROFILE}" > "${PWD}"/phpldapadmin_rd-connect/"${HTTPD_CERTS_FILE}"
	```

	2. Now we build CentOS Apache Web server image, tagging it locally and based on httpd_rd-connect:

	```bash
	HTTPD_TAG=2.4
	docker build -t rd-connect.eu/httpd:${HTTPD_TAG} httpd_rd-connect
	```
	
	3. We augment it with phpldapadmin, which is going to install the needed certificates:
	
	```bash
	PLA_TAG=latest
	docker build --build-arg="HTTPD_CERTS_PROFILE=${HTTPD_CERTS_PROFILE}" --build-arg="HTTPD_CERTS_FILE=${HTTPD_CERTS_FILE}" -t rd-connect.eu/phpldapadmin:${PLA_TAG} phpldapadmin_rd-connect
	rm -fr "${PWD}"/rd-connect-CAS-server/tmp
	```
	
	4. We build the rd-connect.eu/rdconnect-umi-prereqs image
	
	```bash
	UMI_TAG=latest
	docker build -t rd-connect.eu/rdconnect-umi-prereqs:${UMI_TAG} umi-prereqs_rd-connect
	```
	
	5. Now we build the rd-connect.eu/rdconnect-umi image that will create container to deploy user management interface
	
	```bash
	UMI_TAG=latest
	docker build --build-arg="CAS_LDAP_PASS=${CAS_LDAP_PASS}" -t rd-connect.eu/rdconnect-umi:${UMI_TAG} umi_rd-connect
	```
	
	3. We generate the umi_data_container based on centos:7 oficial image:
	
	```bash
	docker create -v /var/log/httpd -v /etc/openldap -v /etc/phpldapadmin --name umi_data_container centos:7 /bin/true
	docker cp blblblblblb umi_data_container:/etc/
	```
	
	5. Last, we run rd-connect.eu/umi based on rd-connect.eu/umi:${UMI_TAG} image, giving it a name of `rd-connect.eu_umi` and mounting volumes exported by `umi_data_container`
	
	```bash
	docker run -d --volumes-from umi_data_container --name rd-connect.eu_umi rd-connect.eu/umi:${UMI_TAG}
	```
