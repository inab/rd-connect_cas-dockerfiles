RD-Connect CAS / LDAP containers
================================

Some of the next steps depend on described at [README-CA.md](README-CA.md).

Steps to create the containers
--------------------------------

1. Build CentOS systemd enabled common container, tagging it locally:

	```bash
	docker build -t rd-connect.eu/centos:7 centos_rd-connect
	```

2. Build CentOS Tomcat container (for instance, 7.0.69), tagging it locally:

	```bash
	TOMCAT_TAG=7.0.69
	docker build --build-arg="TOMCAT_TAG=${TOMCAT_TAG}" -t rd-connect.eu/tomcat:${TOMCAT_TAG} -t rd-connect.eu/tomcat:7 tomcat_rd-connect
	```

3. Build RD-Connect OpenLDAP container, along with its images (to be used by CAS):

	```bash
	CAS_TAG=cas-4.1.x
	mkdir -p "${PWD}"/openldap_rd-connect/tmp
	CAS_LDAP_CERTS_FILE=/tmp/cas-ldap-certs.tar
	docker run --volumes-from rd-connect_ca-store rd-connect.eu/rd-connect_ca cas-ldap > "${PWD}"/openldap_rd-connect/"${CAS_LDAP_CERTS_FILE}"
	docker build --build-arg="CAS_LDAP_CERTS_FILE=${CAS_LDAP_CERTS_FILE}" --build-arg="CASBRANCH=${CAS_TAG}" -t rd-connect.eu/cas-ldap:${CAS_TAG} openldap_rd-connect
	rm -f "${PWD}"/openldap_rd-connect/tmp
	```
