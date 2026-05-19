local model = require("model")

local function create_directory(seed_users)
  local directory = model.user_directory.new()
  for _, user in ipairs(seed_users) do
    directory:add_user(user)
  end
  return directory
end

local function format_user_label(user)
  return string.format("%s (%s)", user.name, table.concat(user.roles, ", "))
end

local function require_user(directory, id)
  local user = directory:find_user(id)
  if user == nil then
    error(string.format("User not found: %s", id))
  end
  return user
end

return {
  create_directory = create_directory,
  format_user_label = format_user_label,
  require_user = require_user,
}
