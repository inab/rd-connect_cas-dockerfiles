#!/bin/bash

exec 6>&1
exec 1>&2

echo "This tool will emit the set of keys using tar through STDOUT"

cascadir="${RDCONNECT_CASOFT_DIR:-$(dirname "$0")}"
case "${cascadir}" in
	/*)
		true
		;;
	*)
		cascadir="${PWD}/${cascadir}"
		;;
esac
templatedir="${cascadir}/templates"

keystoreDir="${RDCONNECT_KEYSTORE_DIR:-/etc/rd-connect_keystore}"
keysDir="${keystoreDir}/keys"
CAcert="${keystoreDir}"/cacert.pem
CAkey="${keystoreDir}"/cakey.pem
if [ ! -f "${CAcert}" ] ; then
	mkdir -p "${keysDir}"
	chmod go= "${keystoreDir}"
	
	(umask 277 && certtool --generate-privkey --outfile "${CAkey}")
	certtool --generate-self-signed \
		--template "${cascadir}"/certtool-ca-template.cfg \
		--load-privkey "${CAkey}" \
		--outfile "${CAcert}"
fi

resDir="${RDCONNECT_CERTS_OUT_DIR:-/tmp/rd-connect_certs}"
rm -rf "${resDir}"
mkdir -p "${resDir}"
echo "Adding RD-Connect public key"

#cp -p "${CAcert}" "${resDir}"
ln -s "${CAcert}" "${resDir}"

if [ $# -gt 0 ]; then
	for cert in "$@" ; do
		certtemplate="${templatedir}/${cert}.cfg"
		if [ ! -f "${certtemplate}" ] ; then
			echo "[ERROR] Template for certificate '${cert}' does not exist at '${certtemplate}'"
			exit 1
		fi
		certdir="${keysDir}/${cert}"
		if [ ! -f "${certdir}"/cert.pem ] ; then
			mkdir -p "${certdir}"
			
			# First, generate private key
			certtool --generate-privkey --outfile "${certdir}"/key.pem
			
			# Second, generate the public key, based on the profile
			certtool --generate-certificate \
				--template "${certtemplate}" \
				--load-privkey "${certdir}"/key.pem \
				--outfile "${certdir}"/cert.pem \
				--load-ca-certificate "${CAcert}" \
				--load-ca-privkey "${CAkey}"
			
			# Last, generate a p12 keystore, which can be imported into a Java keystore
			certtool --load-ca-certificate "${CAcert}" \
				--load-certificate "${certdir}"/cert.pem --load-privkey "${certdir}"/key.pem \
				--to-p12 --p12-name="${cert}" --password="${cert}" --outder --outfile "${certdir}"/keystore.p12
		fi
		echo "Adding RD-Connect '${cert}' keys"
		#cp --no-preserve=mode,ownership --preserve=timestamps -r "${certdir}" "${resDir}"
		ln -s "${certdir}" "${resDir}"
	done
fi

tar -c -h -C "${resDir}" -f - . 1>&6
