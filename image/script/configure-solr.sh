#!/bin/bash
set -e

# Use classic schema factory
cd /opt/solr/server/solr/vlo/conf/
sed -i -e 's_</config>_<schemaFactory class="ClassicIndexSchemaFactory"/>\n</config>_g' solrconfig.xml

# Set parameter for Solr data directory
cp /opt/solr/bin/solr.in.sh /opt/solr/bin/solr.in.sh.orig
echo "SOLR_OPTS=\"$SOLR_OPTS -Dsolr.data.dir=/opt/solr/server/solr/vlo/data\"" >> /opt/solr/bin/solr.in.sh
