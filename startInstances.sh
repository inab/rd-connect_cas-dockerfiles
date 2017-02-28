#!/bin/sh

HOST_CASPORT=9443
HOST_UMIPORT=9444
HOST_PLAPORT=9445
if [ $# -gt 0 ] ; then
	HOST_UMIPORT="$1"
	if [ $# -gt 1 ] ; then
		HOST_CASPORT="$2"
		if [ $# -gt 2 ] ; then
			HOST_PLAPORT="$2"
		fi
	fi
fi

# OpenLDAP
docker create --name demo_casldap rd-connect.eu/cas-ldap:cas-4.1.x
# CAS Server
docker create --name demo_cas -p "$HOST_CASPORT:9443" --link demo_casldap:ldap.rd-connect.eu rd-connect.eu/rdconnect_cas:cas-4.1.x
# phpLDAPadmin
docker create --name demo_pla -p "$HOST_PLAPORT:443" --link demo_casldap:ldap.rd-connect.eu rd-connect.eu/phpldapadmin:latest
# User Management Interface
docker create --name demo_umi -p "$HOST_UMIPORT:443" --link demo_casldap:ldap.rd-connect.eu --link demo_cas:rdconnectcas.rd-connect.eu rd-connect.eu/rdconnect-umi:latest

echo "RD-Connect CAS is available at https://127.0.0.1:$HOST_CASPORT/cas/login"
echo "RD-Connect UMI is available at https://127.0.0.1:$HOST_UMIPORT/user-management/"
echo "RD-Connect phpLDAPadmin is available at https://127.0.0.1:$HOST_PLAPORT/phpldapadmin/"
echo

tempF="$(tempfile)"
docker cp demo_casldap:/etc/openldap/for_sysadmin.txt "$tempF"
casPass="$(grep '^rootPass' "$tempF" | cut -f 2 -d =)"
domainPass="$(grep '^domainPass' "$tempF" | cut -f 2 -d =)"
echo "CAS Credentials => user: platform@rd-connect.eu ; password: $casPass"
echo "PLA Credentials => user: cn=admin,dc=rd-connect,dc=eu ; password: $domainPass"
echo
echo "To stop the images, run stopInstances.sh"

docker start demo_casldap demo_cas demo_pla demo_umi
