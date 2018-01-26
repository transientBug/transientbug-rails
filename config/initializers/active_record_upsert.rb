require "active_record_upsert"

ActiveRecord::Base.send :extend, ActiveRecordUpsert
