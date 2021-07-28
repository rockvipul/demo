#!/bin/bash
. "$(dirname "$0")/common.sh"
if [ "${BRANCH}" = "master" ]
then
	DEPLOY_ENVIRONMENT="production"
else
	DEPLOY_ENVIRONMENT="review"
fi
if [ -n "${DO_SYNC}" ] && [ "${DO_SYNC}" = "yes" ]
then
	DEPLOY_ENVIRONMENT="sync"
fi
if [ -d "secrets/${DEPLOY_ENVIRONMENT}" ]
then
	rsync -rlDvc secrets/${DEPLOY_ENVIRONMENT}/ ./
fi
