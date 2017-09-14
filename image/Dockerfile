# Based on Solr/alpine image
FROM solr:alpine

# Create a core
RUN bin/solr start \
	&& bin/solr create_core -c vlo \
	&& bin/solr stop

# Copy configuration
COPY tmp/solr-conf/* /opt/solr/server/solr/vlo/conf/
COPY tmp/solr-conf/xslt/* /opt/solr/server/solr/vlo/conf/xslt/

# Configure solr settings
RUN mkdir /home/solr/script
COPY script/* /home/solr/script/
RUN /home/solr/script/configure-solr.sh

# TODO: insert configuration

