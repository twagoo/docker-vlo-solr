VLO_DISTRIBUTION_PACKAGE="https://github.com/clarin-eric/VLO/releases/download/vlo-4.2.1/vlo-4.2.1-Distribution.tar.gz"
SOLR_CONF_PACKAGE="https://github.com/clarin-eric/VLO/archive/issue87.tar.gz"
SOLR_CONF_DIR="vlo-web-app/src/test/resources/solr/collection1"

IMAGE_QUALIFIED_NAME="$PROJECT_NAME:${TAG}"
IMAGE_QUALIFIED_NAME_WITH_DATA="${PROJECT_NAME}-data:${TAG}"

IMAGE_DIR="${BASEDIR}/image"
IMAGE_TMP_DIR="${IMAGE_DIR}/tmp"
SOLR_CONF_TARGET_DIR="${IMAGE_TMP_DIR}/solr-conf"

VLO_TMP_DIR="${TMPDIR}/vlo-$(date +'%s')"
SOLR_CONF_TMP_DIR="${TMPDIR}/vlo-solr-$(date +'%s')"

if [ -z "${DATAROOT_DIR}" ]
then
	
	DATAROOT_DIR="$(cd ${BASEDIR}; pwd)/sample-data"
fi