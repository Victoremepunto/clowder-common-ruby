require "bundler/inline"
gemfile do
  source 'https://rubygems.org'
  # TODO: point to the right place
  gem "app-common-ruby", path: "/Users/hsong/work/repos/app-common-ruby"
  gem "byebug"
end

require 'ostruct'

arg_config = ENV['ACG_CONFIG']

LoadedConfig = AppConfig.new(JSON.parse(File.read(arg_config)))
puts "LoadedConfig: #{LoadedConfig}"

KafkaTopics = {}.tap do |topics|
  LoadedConfig.kafka.topics.each do |topic|
    topics[topic.requestedName] = topic
  end
end
puts "KafkaTopics: #{KafkaTopics}"

ObjectBuckets = {}.tap do |buckets|
  LoadedConfig.objectStore.buckets.each do |bucket|
    buckets[bucket.requestedName] = bucket
  end
end
puts "ObjectBuckets: #{ObjectBuckets}"

DependencyEndpoints = {}.tap do |endpoints|
  LoadedConfig.endpoints.each do |endpoint|
    endpoints[endpoint.app] = {} unless endpoints.include?(endpoint.app)
    endpoints[endpoint.app][endpoint.name] = endpoint
  end
end
puts "DependencyEndpoints: #{DependencyEndpoints}"

KafkaServers = [].tap do |servers|
  LoadedConfig.kafka.brokers.each do |broker|
    servers << "{#{broker.hostname}}:{#{broker.port}}"
  end
end
puts "KafkaServers: #{KafkaServers}"
