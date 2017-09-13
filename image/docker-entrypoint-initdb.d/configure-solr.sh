#!/bin/bash
set -e

cd /opt/solr/server/solr/vlo/conf/
sed -i -e 's_</config>_<schemaFactory class="ClassicIndexSchemaFactory"/>\n</config>_g' solrconfig.xml
