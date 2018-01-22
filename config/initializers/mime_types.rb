# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

jsonapi_mime = Mime::Type.register "application/vnd.api+json", :json

ActionDispatch::Request.parameter_parsers[jsonapi_mime.symbol] = lambda do |body|
  ActiveSupport::JSON.decode body
end
