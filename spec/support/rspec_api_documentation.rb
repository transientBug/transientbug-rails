require "rspec_api_documentation/dsl"

RspecApiDocumentation.configure do |config|
  config.request_headers_to_include = %w[ Content-Type Accept Host ]
  config.response_headers_to_include = %w[ Content-Type Link ]

  config.format = :json

  # You can define documentation groups as well. A group allows you generate multiple
  # sets of documentation.
  config.define_group :public do |group_config|
    group_config.docs_dir = Rails.root.join("doc", "api", "v1")

    group_config.filter = :api_v1
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: Regexp.new("/spec/acceptance/api/v1/.+_spec.rb")) do |metadata|
    metadata[:document] = true
    metadata[:api_v1] = true
  end
end
