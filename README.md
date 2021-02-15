app-common-ruby
=================

Simple client access library for the config for the Clowder operator.

Based on schema.json, the corresponding Ruby Classes are generated in types.rb.

Testing
-------

export `ACG_CONFIG="test.json"; ruby lib/app-common-ruby/test.rb

Usage
-----

```
require 'app-common-ruby'

@config ||= {}.tap do |options|
  if ENV["CLOWDER_ENABLED"].present? # recommended for backward compatibility    
    config = AppCommonRuby::Config.load # uses ENV['ACG_CONFIG'] or you can provide the path as a method param
    
    options["webPorts"]         = config.webPort
    options["databaseHostname"] = config.database.hostname
    options["kafkaTopics"]      = config.kafka_topics
    # ...
  else
    options["webPorts"] = 3000
    options["databaseHostname"] = ENV['DATABASE_HOST']
  end
end
```

See [test.json](test.json) for all available values

### Kafka Topics

Topics are structured as a hash `<requested_name> => <name>` 
where requested_name is equal to the key topicName in your ClowdApp Custom Resource Definition(CRD)'s yaml

If your kafka is deployed in `local` or `app-interface` mode (see [doc](https://clowder-operator.readthedocs.io/en/latest/providers/kafka.html))
the `name` is equal to the `requested_name`.
