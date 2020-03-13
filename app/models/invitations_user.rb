# frozen_string_literal: true

# == Schema Information
#
# Table name: invitations_users
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  invitation_id :bigint           not null
#  user_id       :bigint
#
# Indexes
#
#  index_invitations_users_on_invitation_id  (invitation_id)
#  index_invitations_users_on_users_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (invitation_id => invitations.id)
#  fk_rails_...  (user_id => users.id)
#
class InvitationsUser < ApplicationRecord
  belongs_to :invitation
  belongs_to :user, optional: true
end
