class Bookmark < ApplicationRecord
  belongs_to :user

  has_many :tags, through: :bookmarks_tags

  before_validation :save_uri
  after_create :schedule_cache

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

  def schedule_cache
    CacheWebpageJob.perform_later bookmark: self
  end
end
