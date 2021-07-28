#!/bin/bash
BINDIR=$(dirname $0)
cd "${BINDIR}/.."
export DIR=$(pwd)
export UNAME=$(uname)
set -e
[ "${UNAME}" == "Darwin" ] && [ -f ~/.bash_profile ] && source ~/.bash_profile
[ "${UNAME}" == "Darwin" ] && alias sed=$(command -v gsed)
VARIABLE_NAMES=""
for SOURCE_FILE in .env .env.local
do
	if [ -f "${SOURCE_FILE}" ]
	then
		if [ -n "${VARIABLE_NAMES}" ]
		then
			VARIABLE_NAMES="${VARIABLE_NAMES}|"
		fi 
		VARIABLE_NAMES="${VARIABLE_NAMES}$(grep = "${SOURCE_FILE}" | grep -v '#' | cut -d= -f1 | xargs | sed -e 's/ /|/g')"
	fi
done
if env | grep -q -E "^(${VARIABLE_NAMES})="
then
	VARIABLES=$(env| grep -E "^(${VARIABLE_NAMES})=")
fi
for SOURCE_FILE in .env .env.local
do
	if [ -f "${SOURCE_FILE}" ]
	then
		source "${SOURCE_FILE}"
		export $(grep = "${SOURCE_FILE}" | grep -v '#' | cut -d= -f1)
	fi
done
if [ -n "${VARIABLES}" ]
then
	export ${VARIABLES}
fi
BRANCH=${CI_COMMIT_REF_NAME:-${CI_BUILD_REF_NAME:-${TRAVIS_BRANCH:-${BRANCH_NAME:-${BRANCH}}}}}
if [ -z "${BRANCH}" ] && [ -d .git ]
then
	BRANCH=$(git rev-parse --abbrev-ref HEAD)
	if [ "${BRANCH}" == "HEAD" ]
	then
		BRANCH=$(git branch --remote --verbose --no-abbrev --contains | sed -rne 's/^[^\/]*\/([^\ ]+).*$/\1/p' | grep -v HEAD)
	fi
fi
PROJECT_PATH=${CI_PROJECT_PATH}
if [ -z "${PROJECT_PATH}" ] && [ -d .git ]
then
	PROJECT_PATH="corporate/$(git remote -v | grep fetch | awk '{print $2}' | sed -e 's#.*/##g' | sed -e 's/.git//g')"
fi
COMMIT_SHA=${CI_COMMIT_SHA}
if [ -z "${COMMIT_SHA}" ] && [ -d .git ]
then
	COMMIT_SHA=""
fi
export BRANCH PROJECT_PATH COMMIT_SHA
export JOB=${CI_JOB_ID:-${CI_BUILD_ID:-${TRAVIS_BUILD_NUMBER:-${BUILD_NUMBER:-1}}}}
[[ ! ${JOB} =~ ^[0-9]+$ ]] && export JOB=1
export REGISTRY_TOKEN=${REGISTRY_TOKEN:-${CI_JOB_TOKEN}}
export REGISTRY_IMAGE=${REGISTRY_IMAGE:-${CI_REGISTRY_IMAGE}}
export REGISTRY=$(echo ${REGISTRY_IMAGE} | sed -E 's#/.*##g')
[ -z "${DOMAIN}" ] && basename "${DIR}" | grep -q '\.' && export DOMAIN=$(basename ${DIR}) || true
