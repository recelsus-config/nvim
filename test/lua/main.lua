package.path = package.path .. ";./?.lua"

local service = require("service")

local seed_users = {
  { id = "u-001", name = "Ada", roles = { "admin", "developer" } },
  { id = "u-002", name = "Grace", roles = { "developer" } },
  { id = "u-003", name = "Linus", roles = { "reviewer" } },
}

local directory = service.create_directory(seed_users)
local selected = service.require_user(directory, "u-001")

print(service.format_user_label(selected))
for _, admin in ipairs(directory:list_admins()) do
  print(string.format("admin: %s", service.format_user_label(admin)))
end
