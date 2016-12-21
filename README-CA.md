RD-Connect CAS / LDAP containers
================================

Steps to create the common key generator container
--------------------------------------------

1. Create data container, which will hold the storage:

	```bash
	docker create -v /etc/rd-connect_keystore --name ca_data_container centos:7 /bin/true
	```

2. Build container, tagging it locally:

	```bash
	docker build -t rd-connect.eu/rd-connect_ca:0.1 -t rd-connect.eu/rd-connect_ca:latest rd-connect-common-key-generator
	```

3. If you have to generate and get the certificates for another container (in the example, store in the directory `customdirectory` the certificates needed for `cas-ldap`), the commands are:

	```bash
	docker run --volumes-from rd-connect_ca-store rd-connect.eu/rd-connect_ca cas-ldap > cas-ldap-certs.tar
	
	```
