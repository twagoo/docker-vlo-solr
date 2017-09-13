# Based on Solr/alpine image
FROM solr:alpine

# Create a core
RUN bin/solr start \
	&& bin/solr create_core -c vlo \
	&& bin/solr stop

