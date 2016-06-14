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

