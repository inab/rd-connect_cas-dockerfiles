RD-Connect CAS / LDAP containers
================================

Steps to create the common key generator container
--------------------------------------------

1. Create data container, which will hold the storage:

	```bash
	docker create -v /etc/rd-connect_keystore --name ca_data_container centos:7 /bin/true
	```

2. Build CentOS common container, tagging it locally:

	```bash
	docker build -t rd-connect.eu/centos:7 centos_rd-connect
	```

3. Build common key generator container, tagging it locally:

	```bash
	docker build -t rd-connect.eu/ca_data_container:0.1 -t rd-connect.eu/ca_data_container:latest rd-connect-common-key-generator
	```

4. If you have to generate and get the certificates for another container (in the example, store in the directory `customdirectory` the certificates needed for `cas-ldap`), the commands are:

	```bash
	docker run --volumes-from rd-connect_ca-store rd-connect.eu/ca_data_container cas-ldap > cas-ldap-certs.tar
	
	```
