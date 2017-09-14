#!/bin/bash
set -e

PROJECT_NAME=vlo-solr
VERSION=1.0

#VLO_DISTRIBUTION_PACKAGE="https://github.com/clarin-eric/VLO/releases/download/vlo-4.2.1/vlo-4.2.1-Distribution.tar.gz"
VLO_DISTRIBUTION_PACKAGE="file:/Users/twagoo/Desktop/vlo-solr6.tar.gz"
VLO_SOLR_CONF_DIR="collection1"

#TODO: use extracted VLO distribution as VLO directory
VLO_DIR="/Users/twagoo/Desktop/vlo-4.2.1"

REV=$(git rev-parse --short HEAD)
TAG=1.0-SNAPSHOT-${REV:-latest}
IMAGE_QUALIFIED_NAME="$PROJECT_NAME:${TAG}"

BASEDIR=$(dirname "$0")
IMAGE_DIR="${BASEDIR}/image"
IMAGE_TMP_DIR="${IMAGE_DIR}/tmp"
SOLR_CONF_TARGET_DIR="${IMAGE_TMP_DIR}/solr-conf"

VLO_TMP_DIR="${TMPDIR}/vlo-$(date +'%s')"

if [ -d "${IMAGE_TMP_DIR}" ]
then
	rm -rf "${IMAGE_TMP_DIR}"
fi
mkdir -p "${IMAGE_TMP_DIR}"
mkdir -p "${VLO_TMP_DIR}"

# Retrieve VLO distribution
echo "Retrieving and unpacking VLO distribution..."
(cd ${VLO_TMP_DIR} &&
	curl -L\# ${VLO_DISTRIBUTION_PACKAGE}| tar zx --strip-components=1)

# Prepare config
cp -R "${VLO_TMP_DIR}/${VLO_SOLR_CONF_DIR}" "${SOLR_CONF_TARGET_DIR}"

# Build image
echo "Building ${IMAGE_QUALIFIED_NAME}"
(cd $IMAGE_DIR && 
	docker build --tag="$IMAGE_QUALIFIED_NAME" .)
	
# Run import and commit
# TODO: make option to toggle this behaviour
echo "Adapting VLO importer configuration"
# Configure to connect to instance
sed -e 's_<solrUrl>.*</solrUrl>_<solrUrl>http://localhost:8983/solr/collection1/</solrUrl>_g' ${VLO_DIR}/config/VloConfig.xml > ${VLO_DIR}/config/VloConfig-docker.xml
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
${VLO_DIR}/bin/vlo_solr_importer.sh -c ${VLO_DIR}/config/VloConfig-docker.xml
echo "Stopping Solr container"
docker stop vlo_solr_import
# TODO: Commit to image
docker rm vlo_solr_import

echo -e "\n\nDone! To start, run the following command: 

	docker run --name vlo_solr -d -p 8983:8983 -t ${IMAGE_QUALIFIED_NAME}
	
Then visit:

	http://localhost:8983/solr/"

rm -rf ${IMAGE_TMP_DIR}
rm -rf ${VLO_TMP_DIR}
