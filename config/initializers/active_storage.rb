module ActiveStorage
  class Service::S3Service < Service
    cattr_accessor :prefix

    def object_for(key)
      bucket.object("#{ prefix }/#{ key }")
    end
  end
end
