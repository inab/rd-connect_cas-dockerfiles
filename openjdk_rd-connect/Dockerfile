FROM	rd-connect.eu/centos:7

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	description="OpenJDK 8 for different RD-Connect CentOS based images" vendor="BSC-CNS" version="8" maintainer="José María Fernández <jose.m.fernandez@bsc.es>"

RUN	yum -y update && yum install -y java-1.8.0-openjdk-devel && yum clean all && rm -rf /var/cache/yum
