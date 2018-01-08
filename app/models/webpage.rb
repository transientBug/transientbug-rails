class Webpage < ApplicationRecord
  before_validation :save_uri

  validates :uri_string, presence: true

  def uri
    @uri ||= Addressable::URI.parse(uri_string)
  end

  def uri= uri_like
    if uri_like.is_a? Addressable::URI
      @uri = uri_like
    else
      @uri = Addressable::URI.parse uri_like.to_s
    end
  end

  private

  def save_uri
    self.uri_string = uri.to_s
  end
end
