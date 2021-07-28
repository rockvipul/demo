#!/bin/bash
. "$(dirname "$0")/common.sh"
if [ "${BRANCH}" = "master" ] ;
then
	DEPLOY_ENVIRONMENT="production"
else
	DEPLOY_ENVIRONMENT="development"
fi
case "${BRANCH}" in
	master)
	    theme deploy -n -e production
		;;
	develop)
	    theme deploy -n -e development
		;;
	*)
		echo "No deploy environment configured"
		;;
esac

