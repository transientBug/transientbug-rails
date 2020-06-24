# frozen_string_literal: true

require "rspec_api_documentation/dsl"

module RspecApiDocumentation
  class RackTestClient < ClientBase
    def response_body
      last_response.body.encode("utf-8")
    end
  end
end

RspecApiDocumentation.configure do |config|
  config.request_headers_to_include = [ "Content-Type", "Accept" ]
  config.response_headers_to_include = [ "Content-Type" ]

  config.format = :json

  config.define_group :api_v1 do |group_config|
    group_config.docs_dir = Rails.root.join("doc/api/v1")

    group_config.filter = :api_v1
  end
end

RSpec.configure do |config|
  config.define_derived_metadata(file_path: Regexp.new("/spec/acceptance/api/v1/.+_spec.rb")) do |metadata|
    metadata[:document] = :api_v1
  end
end
