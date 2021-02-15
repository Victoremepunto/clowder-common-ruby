require 'ostruct'
require 'json'
require_relative 'types'

module AppCommonRuby
  class Config < AppConfig
    def self.load(acg_config = ENV['ACG_CONFIG'] || 'test.json')
      unless File.exist?(acg_config)
        raise "ERROR: #{acg_config} does not exist"
      end

      new(acg_config)
    end

    def initialize(acg_config)
      super(JSON.parse(File.read(acg_config)))
      kafka_servers
      kafka_topics
      object_buckets
      dependency_endpoints
      private_dependency_endpoints
    end

    def kafka_servers
      @kafka_servers ||= [].tap do |servers|
        kafka.brokers.each do |broker|
          servers << "{#{broker.hostname}}:{#{broker.port}}"
        end
      end
    end

    def kafka_topics
      @kafka_topics ||= {}.tap do |topics|
        kafka.topics.each do |topic|
          next if topic.requestedName.nil?

          topics[topic.requestedName] = topic
        end
      end
    end

    def object_buckets
      @object_buckets ||= {}.tap do |buckets|
        objectStore.buckets.each do |bucket|
          next if bucket.requestedName.nil?

          buckets[bucket.requestedName] = bucket
        end
      end
    end

    def dependency_endpoints
      @dependency_endpoints ||= {}.tap do |endpts|
        endpoints.each do |endpoint|
          next if endpoint.app.nil? || endpoint.name.nil?

          endpts[endpoint.app]                = {} unless endpts.include?(endpoint.app)
          endpts[endpoint.app][endpoint.name] = endpoint
        end
      end
    end

    def private_dependency_endpoints
      @private_dependency_endpoints ||= {}.tap do |priv_endpts|
        privateEndpoints.each do |endpoint|
          next if endpoint.app.nil? || endpoint.name.nil?

          priv_endpts[endpoint.app]                = {} unless priv_endpts.include?(endpoint.app)
          priv_endpts[endpoint.app][endpoint.name] = endpoint
        end
      end
    end
  end
end
