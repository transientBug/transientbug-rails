return if File.split($PROGRAM_NAME).last == 'rake'

return if defined?(Rails::Console)
return unless defined?(Rails::Server)

hostname = "#{ `whoami`.strip }@#{ `hostname`.strip }"
# host = Rails::Server.new.options[:Host] || 'localhost'
port = Rails::Server.new.options[:Port] || ENV['PORT'] || 3000

return unless Rails.env.development?

require "dnssd"

tr = DNSSD::TextRecord.new "service" => "transientBug-API"

DNSSD.register hostname, "_http._tcp", "local", port.to_i, tr.encode do |register_reply|
  puts "Bonjour registration: #{ register_reply.inspect }"
end
