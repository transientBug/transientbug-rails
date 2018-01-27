require "rspec_api_documentation/dsl"

RspecApiDocumentation.configure do |config|
  config.request_headers_to_include = %w[ Content-Type Accept ]
  config.response_headers_to_include = %w[ Content-Type ]

  config.format = :json

  config.define_group :api_v1 do |group_config|
    group_config.docs_dir = Rails.root.join("doc", "api", "v1")

    group_config.filter = :api_v1
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: Regexp.new("/spec/acceptance/api/v1/.+_spec.rb")) do |metadata|
    metadata[:document] = :api_v1
  end
end
