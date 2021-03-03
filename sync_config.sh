#!/bin/bash
cd bin/
wget https://raw.githubusercontent.com/RedHatInsights/clowder/master/controllers/cloud.redhat.com/config/schema.json -O schema.json
./json_schema_ruby -o ../lib/clowder-common-ruby/types.rb schema.json
