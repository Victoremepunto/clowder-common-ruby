require 'app-common-ruby'
require 'climate_control'

describe AppCommonRuby::Config do
  around do |example|
    ClimateControl.modify(:ACG_CONFIG => "./test.json") { example.call }
  end

  subject { described_class.load }

  it "should have KafkaTopics" do
    topic_config = subject.kafka_topics["originalName"]

    expect(topic_config.class).to eq(AppCommonRuby::TopicConfig)
    expect(topic_config.requestedName).to eq("originalName")
    expect(topic_config.name).to eq("someTopic")
    expect(topic_config.consumerGroup).to eq("someGroupName")
  end

  it "should have ObjectBuckets" do
    bucket = subject.object_buckets["reqname"]

    expect(bucket.class).to eq(AppCommonRuby::ObjectStoreBucket)
    expect(bucket.requestedName).to eq("reqname")
    expect(bucket.accessKey).to eq("accessKey1")
    expect(bucket.secretKey).to eq("secretKey1")
    expect(bucket.name).to eq("name")
  end

  it "should have DependencyEndpoints" do
    expect(subject.dependency_endpoints.count).to eq(2)
    expect(subject.dependency_endpoints["app1"]["endpoint1"].class).to eq(AppCommonRuby::DependencyEndpoint)
    expect(subject.dependency_endpoints["app2"]["endpoint2"].class).to eq(AppCommonRuby::DependencyEndpoint)

    expect(subject.dependency_endpoints["app1"]["endpoint1"].hostname).to eq("endpoint1.svc")
    expect(subject.dependency_endpoints["app1"]["endpoint1"].port).to eq(8000)
    expect(subject.dependency_endpoints["app2"]["endpoint2"].hostname).to eq("endpoint2.svc")
    expect(subject.dependency_endpoints["app2"]["endpoint2"].port).to eq(8000)
  end


  it "should have PrivateDependencyEndpoints" do
    expect(subject.private_dependency_endpoints.count).to eq(2)
    expect(subject.private_dependency_endpoints["app1"]["endpoint1"].class).to eq(AppCommonRuby::PrivateDependencyEndpoint)
    expect(subject.private_dependency_endpoints["app2"]["endpoint2"].class).to eq(AppCommonRuby::PrivateDependencyEndpoint)

    expect(subject.private_dependency_endpoints["app1"]["endpoint1"].hostname).to eq("endpoint1.svc")
    expect(subject.private_dependency_endpoints["app1"]["endpoint1"].port).to eq(10000)
    expect(subject.private_dependency_endpoints["app2"]["endpoint2"].hostname).to eq("endpoint2.svc")
    expect(subject.private_dependency_endpoints["app2"]["endpoint2"].port).to eq(10000)
  end

  it "should have KafkaServers" do
    expect(subject.kafka_servers.count).to eq(1)
    expect(subject.kafka_servers.first).to eq("{broker-host}:{27015}")
  end
end
