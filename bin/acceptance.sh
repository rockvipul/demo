#!/bin/bash
. "$(dirname "$0")/common.sh"
if [ "${BRANCH}" = "master" ] ;
then
	DEPLOY_ENVIRONMENT="production"
else
	DEPLOY_ENVIRONMENT="development"
fi
export CYPRESS_BASE_URL=https://${DOMAIN}
export CYPRESS_DEPLOY_ENVIRONMENT=${DEPLOY_ENVIRONMENT}
set +e
JOBS=""
for FILE in $(find tests/cypress/integration/ -type f)
do
	cypress run --reporter-options "mochaFile=build/test/cypress.[hash].xml,rootSuiteTitle=Cypress root suite (${DEPLOY_ENVIRONMENT}),testsuitesTitle=Cypress (${DEPLOY_ENVIRONMENT})" --spec "${FILE}" &
	JOBS="${JOBS} $!"
done
wait ${JOBS}
exit 0
