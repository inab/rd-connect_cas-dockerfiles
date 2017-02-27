#!/bin/sh

dockerFileDir="$(dirname "$0")"
case "${dockerFileDir}" in
	/*)
		true
		;;
	*)
		dockerFileDir="${PWD}"/"${dockerFileDir}"
		;;
esac

# This is a data container needed by CA
cd "${dockerFileDir}"
docker create -v /etc/rd-connect_keystore --name rd-connect_ca-store centos:7 /bin/true

# From this point, any failure will stop the batch script
set -e

# Common image
docker build -t rd-connect.eu/centos:7 centos_rd-connect

######
# CA #
######
docker build -t rd-connect.eu/rd-connect_ca:0.3 -t rd-connect.eu/rd-connect_ca:latest rd-connect-common-key-generator

################
# CAS OpenLDAP #
################

# Certificates
CAS_TAG=cas-4.1.x
CAS_LDAP_CERTS_FILE=/tmp/cas-ldap-certs.tar
LDAP_CERTS_PROFILE=cas-ldap
mkdir -p "${dockerFileDir}"/openldap_rd-connect/tmp
docker run --volumes-from rd-connect_ca-store rd-connect.eu/rd-connect_ca "${LDAP_CERTS_PROFILE}" > "${dockerFileDir}"/openldap_rd-connect/"${CAS_LDAP_CERTS_FILE}"

# CAS OpenLDAP image
docker build --build-arg="LDAP_CERTS_PROFILE=${LDAP_CERTS_PROFILE}" --build-arg="CAS_LDAP_CERTS_FILE=${CAS_LDAP_CERTS_FILE}" -t rd-connect.eu/cas-ldap:${CAS_TAG} openldap_rd-connect
rm -fr "${dockerFileDir}"/openldap_rd-connect/tmp

######################
# CAS+CAS Management #
######################

# Certificates
CAS_TOMCAT_CERTS_FILE=/tmp/cas-tomcat-certs.tar
CAS_CERTS_PROFILE=cas-tomcat
mkdir -p "${dockerFileDir}"/rd-connect-CAS-server/tmp
docker run --volumes-from rd-connect_ca-store rd-connect.eu/rd-connect_ca "${CAS_CERTS_PROFILE}" > "${dockerFileDir}"/rd-connect-CAS-server/"${CAS_TOMCAT_CERTS_FILE}"

# Dependency: OpenJDK image
docker build -t rd-connect.eu/openjdk:7 openjdk_rd-connect

# Dependency: Tomcat, image
TOMCAT_TAG=7.0.75
docker build --build-arg="TOMCAT_TAG=${TOMCAT_TAG}" -t rd-connect.eu/tomcat:${TOMCAT_TAG} -t rd-connect.eu/tomcat:7 tomcat_rd-connect

# CAS+CAS Management image
CAS_LDAP_PASS="$(docker run -i -t --rm rd-connect.eu/cas-ldap:cas-4.1.x grep '^domainPass' /etc/openldap/for_sysadmin.txt | cut -f 2 -d =)"
docker build --build-arg="CAS_CERTS_PROFILE=${CAS_CERTS_PROFILE}" --build-arg="CAS_TOMCAT_CERTS_FILE=${CAS_TOMCAT_CERTS_FILE}" --build-arg="CAS_LDAP_PASS=${CAS_LDAP_PASS}" --build-arg="CAS_RELEASE=${CAS_TAG}" -t rd-connect.eu/rdconnect_cas:${CAS_TAG} rd-connect-CAS-server
rm -fr "${dockerFileDir}"/rd-connect-CAS-server/tmp

############################################
# User Management Interface + phpLDAPadmin #
############################################

# Certificates
mkdir -p "${dockerFileDir}"/phpldapadmin_rd-connect/tmp
HTTPD_CERTS_FILE=/tmp/cas-httpd-certs.tar
HTTPD_CERTS_PROFILE=cas-httpd
docker run --volumes-from rd-connect_ca-store rd-connect.eu/rd-connect_ca "${HTTPD_CERTS_PROFILE}" > "${dockerFileDir}"/phpldapadmin_rd-connect/"${HTTPD_CERTS_FILE}"

# Dependency: Apache 2.4
HTTPD_TAG=2.4
docker build -t rd-connect.eu/httpd:${HTTPD_TAG} httpd_rd-connect

# Dependency: phpLDAPadmin (plus https certificates) image
PLA_TAG=latest
docker build --build-arg="HTTPD_CERTS_PROFILE=${HTTPD_CERTS_PROFILE}" --build-arg="HTTPD_CERTS_FILE=${HTTPD_CERTS_FILE}" -t rd-connect.eu/phpldapadmin:${PLA_TAG} phpldapadmin_rd-connect
rm -fr "${dockerFileDir}"/rd-connect-CAS-server/tmp

# Dependency: User Management Interface prerequisites image
UMI_TAG=latest
docker build -t rd-connect.eu/rdconnect-umi-prereqs:${UMI_TAG} umi-prereqs_rd-connect

# User Management Interface + phpLDAPadmin image
UMI_TAG=latest
docker build --build-arg="CAS_LDAP_PASS=${CAS_LDAP_PASS}" -t rd-connect.eu/rdconnect-umi:${UMI_TAG} umi_rd-connect
