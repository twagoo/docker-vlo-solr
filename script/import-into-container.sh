#!/bin/bash
set -e

SOLR_PORT=8984

#expecting the following exported variables (see main build script)
if [ -z "${BASEDIR}" ] || [ -z "${VLO_TMP_DIR}" ] || [ -z "${DATAROOT_DIR}" ] || [ -z "${IMAGE_QUALIFIED_NAME}" ] || [ -z "${IMAGE_QUALIFIED_NAME_WITH_DATA}" ]
then
	echo "Missing variable value(s)"
	exit 1
fi

echo "Adapting VLO importer configuration"
# Configure to connect to instance
sed -e "s_<solrUrl>.*</solrUrl>_<solrUrl>http://localhost:${SOLR_PORT}/solr/collection1/</solrUrl>_g" ${VLO_TMP_DIR}/config/VloConfig.xml > ${VLO_TMP_DIR}/config/VloConfig-docker.xml

# Prepare data roots
sed -e "s@__DATAROOT_DIR__@${DATAROOT_DIR}@g" ${BASEDIR}/vlo-config/dataroots-docker.xml > ${VLO_TMP_DIR}/config/dataroots-docker.xml
sed -i -e 's_<xi:include href="dataroots-production.xml"_<xi:include href="dataroots-docker.xml"_g' ${VLO_TMP_DIR}/config/VloConfig-docker.xml

# Use built-in mapping files (remove file path prefix)
sed -i -e 's_file:/srv/VLO-mapping__g' ${VLO_TMP_DIR}/config/VloConfig-docker.xml

echo "Starting Solr container"
docker run --name vlo_solr_import -d -p ${SOLR_PORT}:8983 -t ${IMAGE_QUALIFIED_NAME}
# Wait for Solr to come online
sleep 5
while ! curl -s "http://localhost:${SOLR_PORT}/solr"
do
	echo Waiting...
	sleep 5
done
sleep 5
echo "Running importer"
(cd ${VLO_TMP_DIR}/bin && ./vlo_solr_importer.sh -c ${VLO_TMP_DIR}/config/VloConfig-docker.xml)
cp ${VLO_TMP_DIR}/log/*.log .
echo "Stopping Solr container"
docker stop vlo_solr_import
echo "Committing to ${IMAGE_QUALIFIED_NAME_WITH_DATA}" 
docker commit vlo_solr_import ${IMAGE_QUALIFIED_NAME_WITH_DATA}
docker rm vlo_solr_import
