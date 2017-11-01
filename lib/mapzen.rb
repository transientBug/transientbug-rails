class Mapzen
  URL_TEMPLATES = {
    search: "https://search.mapzen.com/v1/search{?api_key,text}"
  }.freeze

  class APIError < StandardError; end

  def initialize token:
    @token         = token

    @url_templates = URL_TEMPLATES.each_with_object({}) do |(key, template), memo|
      memo[ key ] = Addressable::Template.new(template).partial_expand(api_key: token)
    end

    @client        = HTTP.headers(
      user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:57.0) Gecko/20100101 Firefox/57.0",
      accept_language: "en-US,en;q=0.5",
      accept: "application/json;q=0.9,*/*;q=0.8; charset=utf-8"
    )
  end

  def search query:
    res = @client.get @url_templates[:search].generate(text: query)

    status = res.status

    fail APIError, status if status != 200

    parsed_response = JSON.parse res.body, symbolize_names: true

    parsed_response
  end
end
