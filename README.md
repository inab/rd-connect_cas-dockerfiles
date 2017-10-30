RD-Connect CAS / LDAP / UMI containers
==================================

* `generateImages.sh` script automates the RD-Connect CAS images generation with a set of random passwords and self-signed certificates.
* Once run, `startInstances.sh` allows creating instances based on all the main images, and starting them. `stopInstances.sh` stops those instances.

Instructions
----------------------------------

1. Download the code

	```bash
	git clone https://github.com/inab/rd-connect_cas-dockerfiles.git
	```
2. Enter the directory

  	```bash
  	cd rd-connect_cas-dockerfiles
  	```
3. Create the images
  
  	```bash
  	./generateImages.sh
  	```
4. (OPTIONAL) If they do not exist, create the data volumes

	```bash
	./initDataVolumes.sh [volumes prefix]
	```

5. (OPTIONAL) If it is needed, populate the data volumes from the initial setup in the images

	```bash
	./populateDataVolumes.sh [volumes prefix]
	```

6. (OPTIONAL) If it is needed, remove previous instances based on previous images

	```bash
	./removeInstances.sh [volumes prefix]
	```

7. Create instances based on newly built images

	```bash
	./createInstances.sh [volumes prefix]
	```

8. Start the instances, using either of these methods:
	a. Using `startInstances.sh` script (it will tell you the random credentials generated for the initial setup).
	  
		```bash
		./startInstances [volumes prefix]
		```

	b. Enter rd-connect-compose directory and run the whole workflow
		
		```bash
		cd rd-connect-compose
		docker-compose up
		```

Steps to create the containers by hand (OUTDATED)
----------------------------------

Some of the next steps depend on described at [README-CA.md](README-CA.md).


1. Build CentOS and OpenJDK common containers, tagging it locally:

	```bash
	docker build -t rd-connect.eu/centos:7 centos_rd-connect
	docker build -t rd-connect.eu/openjdk:8 openjdk_rd-connect
	```
2. Build RD-Connect OpenLDAP container, along with its images (to be used by CAS):

	1. If we do not have already one, we generate the LDAP data volumes:
	
	```bash
	# For /etc/openldap
	docker volume create --name ldap_conf
	# For /var/lib/ldap
	docker volume create --name ldap_db
	# For /var/log
	docker volume create --name ldap_logs
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
	
	2. Build the tomcat image, and generate the data volumes to be used:
	
	```bash
	TOMCAT_TAG=7.0.75
	docker build --build-arg="TOMCAT_TAG=${TOMCAT_TAG}" -t rd-connect.eu/tomcat:${TOMCAT_TAG} -t rd-connect.eu/tomcat:7 tomcat_rd-connect
	# For /etc/cas
	docker volume create --name cas_conf
	# For /etc/tomcat8
	docker volume create --name tomcat_conf
	# For /var/log
	docker volume create --name cas_logs
	```
	
	3. Extract the LDAP admin password from RD-Connect OpenLDAP container
	
	```bash
	CAS_LDAP_PASS="$(docker run --rm rd-connect.eu/cas-ldap:cas-4.1.x grep '^domainPass' /etc/openldap/for_sysadmin.txt | cut -f 2 -d =)"
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
	
	3. We generate the data volumes needed by UMI:
	
	```bash
	# /var/log/httpd
	docker volume create --name pla_logs
	# /etc/openldap -> you can create a separate volume for it, or reuse ldap_conf data volume
	docker volume create --name pla_ldap
	# /etc/phpldapadmin
	docker volume create --name pla_conf
	docker cp blblblblblb umi_data_container:/etc/
	```
	
	5. Last, we run rd-connect.eu/umi based on rd-connect.eu/umi:${UMI_TAG} image, giving it a name of `rd-connect.eu_umi` and mounting volumes exported by `umi_data_container`
	
	```bash
	docker run -d --volumes-from umi_data_container --name rd-connect.eu_umi rd-connect.eu/umi:${UMI_TAG}
	```
