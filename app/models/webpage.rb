class Webpage < ApplicationRecord
  has_many :bookmarks

  before_validation :save_uri

  validates :uri_string, presence: true, uniqueness: true

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

  # Cleans up the URI, removing fragments (bits after the #) and converts the
  # Addressable object into a string for storage
  def save_uri
    self.uri_string = uri.omit(:fragment).to_s
  end
end
