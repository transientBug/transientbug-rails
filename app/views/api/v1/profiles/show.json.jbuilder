json.data do
  json.partial! "api/v1/profiles/profile", profile: current_user
end
