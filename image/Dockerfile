# Based on Solr/alpine image
FROM solr:alpine

# Create a core
RUN bin/solr start \
	&& bin/solr create_core -c collection1 \
	&& bin/solr stop

# Replace configuration, removing managed schema so that it gets created from the 
# 'classic' schema.xml file provided by the VLO
RUN rm -f \
	/opt/solr/server/solr/collection1/conf/managed-schema \
	/opt/solr/server/solr/collection1/conf/solrconfig.xml \
	/opt/solr/server/solr/collection1/conf/*.txt
COPY tmp/solr-conf/ /opt/solr/server/solr/collection1/

# Configure solr settings
RUN mkdir /home/solr/script
COPY script/* /home/solr/script/
RUN /home/solr/script/configure-solr.sh

# Make sure the entire core is readable and writable by the solr user
USER root
RUN chown -R solr:solr /opt/solr/server/solr/collection1/

USER solr
