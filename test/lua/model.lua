local user_directory = {}
user_directory.__index = user_directory

function user_directory.new()
  return setmetatable({ users = {} }, user_directory)
end

function user_directory:add_user(profile)
  self.users[profile.id] = profile
end

function user_directory:find_user(id)
  return self.users[id]
end

function user_directory:list_admins()
  local admins = {}
  for _, user in pairs(self.users) do
    for _, role in ipairs(user.roles) do
      if role == "admin" then
        table.insert(admins, user)
        break
      end
    end
  end
  return admins
end

return {
  user_directory = user_directory,
}
