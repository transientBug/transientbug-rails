# frozen_string_literal: true

# == Schema Information
#
# Table name: bookmarks_tags
#
#  id          :bigint           not null, primary key
#  bookmark_id :bigint           not null
#  tag_id      :bigint           not null
#
class BookmarksTag < ApplicationRecord
  belongs_to :bookmark
  belongs_to :tag

  update_index("bookmarks") { bookmark }
end
