#!/bin/bash
DIR=$(dirname "$0")
cd "${DIR}"/.. || return
if [ -d secrets ]
then
	if [ -z "${OPENSSL_IV_KEY}" ]
	then
		echo -e "\033[1;31mPlease provide OPENSSL_IV_KEY environment variable.\033[0m"
		echo "It contains a string IV:KEY"
		echo "You'll find thoses values inside wiki or you can generate with following command:"
		echo -e "\033[1;32mopenssl enc -aes-256-cbc -k *secret* -P -md sha1\033[0m"
		echo "If you generate new credentials, don't forget to copy then inside wiki AND continuous integration."
		exit 1
	fi
	OPENSSL_IV=$(echo "${OPENSSL_IV_KEY}" | sed -e 's/:/ /g' | awk '{print $1}')
	OPENSSL_KEY=$(echo "${OPENSSL_IV_KEY}" | sed -e 's/:/ /g' | awk '{print $2}')
	tar zcf secrets.tar.gz secrets
	openssl enc -aes-256-cbc -K "${OPENSSL_KEY}" -iv "${OPENSSL_IV}" -in secrets.tar.gz -out secrets.tar.gz.enc
	rm secrets.tar.gz
fi