RD-Connect CAS / LDAP containers
================================

Steps to create the common key generator container (based on volumes)
--------------------------------------------

1. Create data volume, which will hold the storage:

	```bash
	docker volume create --name rd-connect_ca-vol
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
	docker run --rm -v rd-connect_ca-vol:/etc/rd-connect_keystore rd-connect.eu/rd-connect_ca cas-ldap cas-tomcat > cas-certs.tar
	
	```

5. If you need to do a backup of the data volume, you have to run next command:

	```bash
	docker run --rm -v rd-connect_ca-vol:/etc/rd-connect_keystore centos:7 tar -cpO /etc/rd-connect_keystore | gzip -9c > rd-connect_keystore.backup.$(date -Iseconds).tar.gz
	```

6. If you need to do a restore of the data volume, you have to run next command:

	```bash
	gunzip -c rd-connect_keystore.backup.tar.gz | docker run -i --rm -v rd-connect_ca-vol:/etc/rd-connect_keystore centos:7  tar -C / --delay-directory-restore -xpf -
	```

Steps to create the common key generator container (based on data containers)
--------------------------------------------

1. Create data container, which will hold the storage:

	```bash
	docker create -v /etc/rd-connect_keystore --name rd-connect_ca-store busybox /bin/true
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
	docker run --rm --volumes-from rd-connect_ca-store rd-connect.eu/rd-connect_ca cas-ldap cas-tomcat > cas-certs.tar
	
	```

5. If you need to do a backup of the data container, you have to run next command:

	```bash
	docker run --rm --volumes-from rd-connect_ca-store centos:7 tar -cpO /etc/rd-connect_keystore | gzip -9c > rd-connect_keystore.backup.$(date -Iseconds).tar.gz
	```

6. If you need to do a restore of the data container, you have to run next command:

	```bash
	gunzip -c rd-connect_keystore.backup.tar.gz | docker run -i --rm --volumes-from rd-connect_ca-store centos:7 tar -C / --delay-directory-restore -xpf -
	```
