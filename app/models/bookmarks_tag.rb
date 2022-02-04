# frozen_string_literal: true

# == Schema Information
#
# Table name: bookmarks_tags
#
#  bookmark_id :integer          not null
#  tag_id      :integer          not null
#  id          :integer          not null, primary key
#

class BookmarksTag < ApplicationRecord
  belongs_to :bookmark
  belongs_to :tag
end
