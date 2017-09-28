#!/bin/bash
set -e

PROJECT_NAME=vlo-solr
REV=$(git rev-parse --short HEAD)
TAG=1.0-SNAPSHOT-${REV:-latest}
BASEDIR=$(dirname "$0")

source ${BASEDIR}/script/env.sh

if [ -z "${DATAROOT_DIR}" ]
then
	
	DATAROOT_DIR="$(cd ${BASEDIR}; pwd)/sample-data"
fi

IMPORT=0

while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -i|--import)
        IMPORT=1
        ;;
    *)
        echo "Unkown option: $key"
        ;;
esac
shift # past argument or value
done


if [ -d "${IMAGE_TMP_DIR}" ]
then
	rm -rf "${IMAGE_TMP_DIR}"
fi
mkdir -p "${IMAGE_TMP_DIR}"
mkdir -p "${VLO_TMP_DIR}"
mkdir -p "${SOLR_CONF_TMP_DIR}"

# Retrieve VLO distribution
echo "Retrieving and unpacking VLO distribution..."
(cd ${VLO_TMP_DIR} &&
	curl -L\# ${VLO_DISTRIBUTION_PACKAGE}| tar zx --strip-components=1)

echo "Retrieving and unpacking VLO solr configuration..."
(cd ${SOLR_CONF_TMP_DIR} &&
	curl -L\# ${SOLR_CONF_PACKAGE}| tar zx --strip-components=1)

# Prepare config
cp -R "${SOLR_CONF_TMP_DIR}/${SOLR_CONF_DIR}" "${SOLR_CONF_TARGET_DIR}"

# Build image
echo "Building ${IMAGE_QUALIFIED_NAME}"
(cd $IMAGE_DIR && 
	docker build --tag="$IMAGE_QUALIFIED_NAME" .)
	
# Run import and commit
if [ "${IMPORT}" -eq 1 ]; then
	export BASEDIR VLO_TMP_DIR DATAROOT_DIR IMAGE_QUALIFIED_NAME IMAGE_QUALIFIED_NAME_WITH_DATA
	${BASEDIR}/script/import-into-container.sh
fi

echo -e "\n\nDone! To start, run the following command: 

	docker run --name vlo_solr -d -p 8983:8983 -t ${IMAGE_QUALIFIED_NAME}"

if [ "${IMPORT}" -eq 1 ]; then
	echo -e "or: 
	docker run --name vlo_solr -d -p 8983:8983 -t ${IMAGE_QUALIFIED_NAME_WITH_DATA}"
fi
	
echo -e "\nThen visit:

	http://localhost:8983/solr/"

rm -rf ${IMAGE_TMP_DIR}
rm -rf ${VLO_TMP_DIR}
rm -rf ${SOLR_CONF_TMP_DIR}
