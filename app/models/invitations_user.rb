# frozen_string_literal: true

# == Schema Information
#
# Table name: invitations_users
#
#  id            :integer          not null, primary key
#  invitation_id :integer          not null
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_invitations_users_on_invitation_id  (invitation_id)
#  index_invitations_users_on_users_id       (user_id)
#

class InvitationsUser < ApplicationRecord
  belongs_to :invitation
  belongs_to :user, optional: true
end
