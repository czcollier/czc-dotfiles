vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.clipboard = 'unnamedplus'

-- Set Python-specific indentation options
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = true
  end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
-- Setup lazy.nvim
require("lazy").setup({
   spec = {
   {
     'nvim-treesitter/nvim-treesitter',
     build = ':TSUpdate',
     config = function()
       local configs = require("nvim-treesitter.config")
       configs.setup({
         ensure_installed = { 
           'bash', 'c', 'cpp', 'glsl', 'lua', 'java', 'python', 'vim', 'vimdoc', 'query', 'javascript', 'html' 
         },
         highlight = { enable = true },
         indent = { enable = true },
       })
     end,
   },
   { "oxfist/night-owl.nvim", lazy = false, priority = 1000 }
  },
  install = { colorscheme = { "catppuccin" } },
  checker = { enabled = true },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  }
})

vim.o.guifont = "Cousine Nerd Font:h10"
--vim.cmd [[colorscheme catppuccin-mocha]]
vim.g.neovide_transparency = 0.93
vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
]]


vim.keymap.set({'n', 'v'}, 'x', '"_x', { noremap = true })
vim.keymap.set({'n', 'v'}, 'X', '"_X', { noremap = true })
vim.keymap.set({'n', 'v'}, '<leader>d', '"_d', { noremap = true })

vim.opt.termguicolors = true

if vim.g.neovide then
  vim.g.neovide_padding_top = 10
  vim.g.neovide_padding_bottom = 10
  vim.g.neovide_padding_right = 10
  vim.g.neovide_padding_left = 10
end
