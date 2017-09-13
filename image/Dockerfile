# Based on Solr/alpine image
FROM solr:alpine

# Create a core
RUN bin/solr start \
	&& bin/solr create_core -c vlo \
	&& bin/solr stop

# Copy entry point scripts
COPY docker-entrypoint-initdb.d/* /docker-entrypoint-initdb.d/

# Copy configuration
COPY _vlo-solr/opt/solr/server/solr/vlo/conf/* /opt/solr/server/solr/vlo/conf/
COPY _vlo-solr/opt/solr/server/solr/vlo/conf/xslt/* /opt/solr/server/solr/vlo/conf/xslt/
# TODO: insert configuration
