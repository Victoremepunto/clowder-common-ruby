require_relative 'config'

begin
  config = ::AppCommonRuby::Config.load

  puts config.inspect
  puts "-------------------\nConfig #{ENV['ACG_CONFIG']} loaded successfully"
rescue => e
  puts e.message
  exit -1
end
