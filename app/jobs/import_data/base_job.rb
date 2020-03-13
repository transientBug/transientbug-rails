# frozen_string_literal: true

class ImportData::BaseJob < ApplicationJob
  queue_as :default
  attr_reader :import_data

  def perform import_data:
    @import_data = import_data

    return if @import_data.complete?

    each_file_entry do |url, bookmark_data, created_at|
      create_bookmark url, bookmark_data, created_at
    end

    import_data.update complete: true
  end

  protected

  def each_file_entry
    entries = parse_file

    entries.each do |entry|
      yield parse_entry(entry)
    end
  end

  def parse_file
    fail NotImplementedError
  end

  def parse_entry _entry
    fail NotImplementedError
  end

  def create_bookmark url, bookmark_data, created_at
    Bookmark.for(import_data.user, url).tap do |bookmark|
      bookmark.assign_attributes bookmark_data

      bookmark.created_at = created_at if bookmark.new_record?
    end.upsert
  end
end
