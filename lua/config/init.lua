local config_path = vim.fn.stdpath("config") .. "/lua/config"

local files = vim.fn.glob(config_path .. "/*.lua", true, true)

for _, file in ipairs(files) do
  local filename = vim.fn.fnamemodify(file, ":t:r")
  if filename ~= "init" then
    require("config." .. filename)
  end
end
