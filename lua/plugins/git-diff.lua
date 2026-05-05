local function git_ref_exists(ref)
  return vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", ref }) ~= nil
    and vim.v.shell_error == 0
end

local function diff_default_branch()
  local candidates = { "origin/HEAD", "main", "master", "HEAD~1" }

  for _, ref in ipairs(candidates) do
    if git_ref_exists(ref) then
      vim.cmd("DiffviewOpen " .. ref .. "...HEAD")
      return
    end
  end

  vim.notify("No default branch ref found for DiffviewOpen", vim.log.levels.WARN)
end

return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<CR>", desc = "git: diff view" },
      { "<leader>gM", diff_default_branch, desc = "git: diff default" },
      { "<leader>gC", "<cmd>DiffviewClose<CR>", desc = "git: diff close" },
      { "<leader>gF", "<cmd>DiffviewFileHistory %<CR>", desc = "git: file history" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "git: repo history" },
      { "<leader>gT", "<cmd>DiffviewToggleFiles<CR>", desc = "git: diff files toggle" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = {
          layout = "diff2_horizontal",
        },
        merge_tool = {
          layout = "diff3_horizontal",
        },
        file_history = {
          layout = "diff2_horizontal",
        },
      },
      file_panel = {
        listing_style = "tree",
        win_config = {
          position = "left",
          width = 35,
        },
      },
    },
  },
  {
    "tpope/vim-fugitive",
    cmd = {
      "Git",
      "G",
      "Gdiffsplit",
      "Gvdiffsplit",
      "Gedit",
      "Gread",
      "Gwrite",
      "Ggrep",
      "Gclog",
    },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>", desc = "git: status" },
      { "<leader>gv", "<cmd>Gvdiffsplit<CR>", desc = "git: file vsplit diff" },
      { "<leader>gx", "<cmd>Gdiffsplit<CR>", desc = "git: file split diff" },
    },
  },
}
