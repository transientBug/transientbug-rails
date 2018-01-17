class InvitationsUser < ApplicationRecord
  belongs_to :invitation
  belongs_to :user, optional: true
end
