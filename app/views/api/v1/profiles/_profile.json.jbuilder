json.type "profile"
json.id profile.id

json.attributes do
  json.extract! profile, :api_token, :username, :email
  json.api_token profile.api_token
end

json.links do
  json.self api_v1_profile_url
end
