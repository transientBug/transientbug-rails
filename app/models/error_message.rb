# frozen_string_literal: true

# == Schema Information
#
# Table name: error_messages
#
#  id         :bigint           not null, primary key
#  key        :string
#  message    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ErrorMessage < ApplicationRecord
end
