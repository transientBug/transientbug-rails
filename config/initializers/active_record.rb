require "active_record_upsert"
require "addressable_uri_type"

ActiveRecord::Base.send :extend, ActiveRecordUpsert

ActiveRecord::Type.register :addressable_uri, AddressableUriType
