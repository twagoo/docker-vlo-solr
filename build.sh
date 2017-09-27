#!/bin/bash
set -e

PROJECT_NAME=vlo-solr
REV=$(git rev-parse --short HEAD)
TAG=1.0-SNAPSHOT-${REV:-latest}

VLO_DISTRIBUTION_PACKAGE="https://github.com/clarin-eric/VLO/releases/download/vlo-4.2.1/vlo-4.2.1-Distribution.tar.gz"
SOLR_CONF_PACKAGE="https://github.com/clarin-eric/VLO/archive/issue87.tar.gz"
SOLR_CONF_DIR="vlo-web-app/src/test/resources/solr/collection1"

IMAGE_QUALIFIED_NAME="$PROJECT_NAME:${TAG}"
IMAGE_QUALIFIED_NAME_WITH_DATA="${PROJECT_NAME}-data:${TAG}"

BASEDIR=$(dirname "$0")
IMAGE_DIR="${BASEDIR}/image"
IMAGE_TMP_DIR="${IMAGE_DIR}/tmp"
SOLR_CONF_TARGET_DIR="${IMAGE_TMP_DIR}/solr-conf"

VLO_TMP_DIR="${TMPDIR}/vlo-$(date +'%s')"
SOLR_CONF_TMP_DIR="${TMPDIR}/vlo-solr-$(date +'%s')"

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
	echo "Adapting VLO importer configuration"
	# Configure to connect to instance
	sed -e 's_<solrUrl>.*</solrUrl>_<solrUrl>http://localhost:8983/solr/collection1/</solrUrl>_g' ${VLO_TMP_DIR}/config/VloConfig.xml > ${VLO_TMP_DIR}/config/VloConfig-docker.xml
	# TODO: set data roots
	echo "Starting Solr container"
	docker run --name vlo_solr_import -d -p 8983:8983 -t ${IMAGE_QUALIFIED_NAME}
	# Wait for Solr to come online
	sleep 5
	while ! curl -s http://localhost:8983/solr
	do
		echo Waiting...
		sleep 5
	done
	sleep 5
	echo "Running importer"
	${VLO_TMP_DIR}/bin/vlo_solr_importer.sh -c ${VLO_TMP_DIR}/config/VloConfig-docker.xml
	echo "Stopping Solr container"
	docker stop vlo_solr_import
	echo "Committing to ${IMAGE_QUALIFIED_NAME_WITH_DATA}" 
	docker commit vlo_solr_import ${IMAGE_QUALIFIED_NAME_WITH_DATA}
	docker rm vlo_solr_import
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
