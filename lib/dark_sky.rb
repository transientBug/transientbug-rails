class DarkSky
  URL_TEMPLATES = {
    forecast: "https://api.darksky.net/forecast/{token}/{latitude},{longitude}",
    time_machine: "https://api.darksky.net/forecast/{token}/{latitude},{longitude},{time}"
  }.freeze

  class APIError < StandardError; end

  def initialize token:
    @token         = token

    @url_templates = URL_TEMPLATES.each_with_object({}) do |(key, template), memo|
      memo[ key ] = Addressable::Template.new(template).partial_expand(token: token)
    end

    @client        = HTTP.headers(
      user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:57.0) Gecko/20100101 Firefox/57.0",
      accept_language: "en-US,en;q=0.5",
      accept: "application/json;q=0.9,*/*;q=0.8; charset=utf-8"
    )
  end

  def forecast latitude:, longitude:
    res = @client.get @url_templates[:forecast].expand(latitude: latitude, longitude: longitude)

    status = res.status

    fail APIError, status if status != 200

    parsed_response = JSON.parse res.body, symbolize_names: true

    parsed_response[:currently] = handle_data_point parsed_response[:currently]

    [
      [:minutely, :data],
      [:hourly, :data],
      [:daily, :data]
    ].each do |path|
      data_points = parsed_response.dig(*path)
      next unless data_points.present?

      mapped_points = data_points.map do |data_point|
        handle_data_point data_point
      end

      nested = path.reverse.inject(mapped_points) do |key, memo|
        { key => memo }
      end

      parsed_response.merge nested
    end

    parsed_response
  end

  def time_machine latitude:, longitude:, time:
    res = @client.get @url_templates[:time_machine].expand(latitude: latitude, longitude: longitude, time: time.to_i)

    status = res.status

    fail APIError, status if status != 200

    parsed_response = JSON.parse res.body, symbolize_names: true

    parsed_response[:currently] = handle_data_point parsed_response[:currently]

    [
      [:minutely, :data],
      [:hourly, :data],
      [:daily, :data]
    ].each do |path|
      data_points = parsed_response.dig(*path)
      next unless data_points.present?

      mapped_points = data_points.map do |data_point|
        handle_data_point data_point
      end

      nested = path.reverse.inject(mapped_points) do |key, memo|
        { key => memo }
      end

      parsed_response.merge nested
    end

    parsed_response
  end

  protected

  def handle_data_point data_point
    %i{
      time
      sunriseTime
      sunsetTime
      temperatureHighTime
      temperatureLowTime
      apparentTemperatureHighTime
      apparentTemperatureLowTime
      precipIntensityMaxTime
      windGustTime
      uvIndexTime
    }.each do |key|
      data_point[key] = Time.at data_point[key] if data_point.key? key
    end

    data_point
  end
end
