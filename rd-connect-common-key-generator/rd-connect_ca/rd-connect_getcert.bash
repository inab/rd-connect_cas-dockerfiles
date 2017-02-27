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
	# We want it to exit on first error
	set -e
	
	for cert in "$@" ; do
		certtemplate="${templatedir}/${cert}.cfg"
		if [ ! -f "${certtemplate}" ] ; then
			echo "[ERROR] Template for certificate '${cert}' does not exist at '${certtemplate}'"
			exit 1
		fi
		dnsName="$(grep ^dns_name "${certtemplate}" | tr -d ' '| cut -f 2 -d '=')"
		
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
		fi
		
		# Last, generate a p12 keystore, which can be imported into a Java keystore
		if [ ! -f "${certdir}"/keystore.p12 ] ; then
			certtool --load-ca-certificate "${CAcert}" \
				--load-certificate "${certdir}"/cert.pem --load-privkey "${certdir}"/key.pem \
				--to-p12 --p12-name="${dnsName}" --password="${cert}" --outder --outfile "${certdir}"/keystore.p12
		fi
		if [ ! -f "${certdir}"/keystoreOpenSSL.p12 ] ; then
			export cert
			openssl pkcs12 -export -in "${certdir}"/cert.pem -inkey "${certdir}"/key.pem -name "${dnsName}" \
				 -certfile "${CAcert}" -password env:cert -out "${certdir}"/keystoreOpenSSL.p12
		fi
		echo "Adding RD-Connect '${cert}' keys"
		#cp --no-preserve=mode,ownership --preserve=timestamps -r "${certdir}" "${resDir}"
		ln -s "${certdir}" "${resDir}"
	done
fi

# We assure reproducibility with this sentence
touch --date=@0 "$resDir"
tar -c -h -C "${resDir}" -f - . 1>&6
