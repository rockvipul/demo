#!/bin/bash
DIR=$(dirname "$0")
cd "${DIR}"/.. || return
if [ -f secrets.tar.gz.enc ]
then
	if [ -z "${OPENSSL_IV_KEY}" ]
	then
		echo -e "\033[1;31mPlease provide OPENSSL_IV_KEY environment variable.\033[0m"
		echo "It contains a string IV:KEY"
		echo "You'll find thoses values inside wiki."
		exit 0
	fi
	OPENSSL_IV=$(echo "${OPENSSL_IV_KEY}" | sed -e 's/:/ /g' | awk '{print $1}')
	OPENSSL_KEY=$(echo "${OPENSSL_IV_KEY}" | sed -e 's/:/ /g' | awk '{print $2}')
	openssl enc -aes-256-cbc -K "${OPENSSL_KEY}" -iv "${OPENSSL_IV}" -in secrets.tar.gz.enc -out secrets.tar.gz -d
	tar zxf secrets.tar.gz
	rm secrets.tar.gz
fi