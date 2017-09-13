#!/bin/bash
PROJECT_NAME=vlo-solr
VERSION=1.0

REV=$(git rev-parse --short HEAD)
TAG=1.0-SNAPSHOT-${REV:-latest}
IMAGE_QUALIFIED_NAME="$PROJECT_NAME:${TAG}"

BASEDIR=$(dirname "$0")
IMAGE_DIR="${BASEDIR}/image"

# TODO: prepare config

# Build image
echo "Building ${IMAGE_QUALIFIED_NAME}"
(cd $IMAGE_DIR && 
	docker build --tag="$IMAGE_QUALIFIED_NAME" .)
	
# TODO: run import, commit

echo -e "\n\nDone! To start, run the following command: 

	docker run --name vlo_solr -d -p 8983:8983 -t ${IMAGE_QUALIFIED_NAME}
	
Then visit:

	http://localhost:8983/solr/"
