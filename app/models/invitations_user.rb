class InvitationsUser < ApplicationRecord
  belongs_to :invitation
  belongs_to :users, optional: true
end
