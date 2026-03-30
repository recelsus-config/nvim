local config_path = vim.fn.stdpath("config") .. "/lua/config"

local files = vim.fn.globpath(config_path, "**/*.lua", true, true)
table.sort(files)

for _, file in ipairs(files) do
  local rel = file:sub(#config_path + 2):gsub("%.lua$", "")
  if rel ~= "init" and not rel:match("/init$") then
    require("config." .. rel:gsub("/", "."))
  end
end
