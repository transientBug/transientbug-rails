# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

jsonapi_mime = Mime::Type.register "application/vnd.api+json", :json

json_parser = ActionDispatch::Http::Parameters::DEFAULT_PARSERS[ Mime[:json].symbol ]
ActionDispatch::Request.parameter_parsers[jsonapi_mime.symbol] = json_parser
