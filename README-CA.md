RD-Connect CAS / LDAP containers
================================

Steps to create the common key generator container
--------------------------------------------

1. Create data container, which will hold the storage:

	```bash
	docker create -v /etc/rd-connect_keystore --name rd-connect_ca-store centos:7 /bin/true
	```

2. Build CentOS common container, tagging it locally:

	```bash
	docker build -t rd-connect.eu/centos:7 centos_rd-connect
	```

3. Build common key generator container, tagging it locally:

	```bash
	docker build -t rd-connect.eu/rd-connect_ca:0.3 -t rd-connect.eu/rd-connect_ca:latest rd-connect-common-key-generator
	```

4. If you have to generate and get several certificates (in the case of the example, cas-ldap and cas-tomcat profiles) for another container, the command is:

	```bash
	docker run --volumes-from rd-connect_ca-store rd-connect.eu/rd-connect_ca cas-ldap cas-tomcat > cas-certs.tar
	
	```
