class Identity < OmniAuth::Identity::Model
  belongs_to :user
end
