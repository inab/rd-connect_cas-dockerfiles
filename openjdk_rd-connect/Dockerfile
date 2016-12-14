FROM	rd-connect.eu/centos:7
MAINTAINER	José María Fernández <jmfernandez@cnio.es>

# Use a single LABEL (multiple ones are discouraged because each one creates a new layer)
LABEL	Description="OpenJDK 7 for different RD-Connect CentOS based images" Vendor="CNIO" Version="7"

RUN	yum install -y java-1.7.0-openjdk-devel
RUN	yum clean all
