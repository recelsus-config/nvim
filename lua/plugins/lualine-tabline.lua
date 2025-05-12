return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",

    dependencies = { 'nvim-tree/nvim-web-devicons' },

    config = function()
      require('lualine').setup({
        options = {
          icons_enabled = true,  
          theme = 'onedark',     
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          always_divide_middle = true,
        },
        sections = {
          lualine_a = { 'mode' },              
          lualine_b = { 'branch', 'diff', 'diagnostics' }, 
          lualine_c = { 'filename' },          
          lualine_x = { 'encoding', 'fileformat', 'filetype' }, 
          lualine_y = { 'progress' },          
          lualine_z = { 'location' }           
        },
        inactive_sections = {
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
        },
      })
    end
  },

  {
    "kdheepak/tabline.nvim",
    event = "VeryLazy",

    dependencies = { 'nvim-tree/nvim-web-devicons' },

    config = function()
      require('tabline').setup({
        
        enable = true,                
        options = {
          section_separators = { '', '' },  
          component_separators = { '', '' },  
          show_filename_only = true,   
          modified_icon = '●',         
          show_tabs_only = false,      
        }
      })
    end
  }
}

