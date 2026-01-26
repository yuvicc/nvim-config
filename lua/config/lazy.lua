local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar() os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local plugins = {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("catppuccin").setup()
            vim.cmd.colorscheme "catppuccin"
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        version = '0.2.1',
        dependencies = {
            'nvim-lua/plenary.nvim',
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set('n', '<leader>ff', builtin.find_files, {desc = 'Telescope find files'})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {"lua", "cpp", "c", "java", "rust", "python", "bash"},
                highlight = { enable = true },
                indent = { enable = true },
            })
        end,
    },
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            "nvim-tree/nvim-web-devicons",
        },
        lazy = false, 
    },
    {
        "mason-org/mason.nvim",
        opts = {}
    },
    {
        'jeffkreeftmeijer/vim-numbertoggle',
    },
    {
        'tpope/vim-fugitive',
        config = function()
            -- Fugitive keymaps for common git operations
            vim.keymap.set('n', '<leader>gs', ':Git<CR>', { desc = 'Git status' })
            vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', { desc = 'Git commit' })
            vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { desc = 'Git push' })
            vim.keymap.set('n', '<leader>gl', ':Git pull<CR>', { desc = 'Git pull' })
            vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { desc = 'Git blame' })
            vim.keymap.set('n', '<leader>gd', ':Gdiffsplit<CR>', { desc = 'Git diff split' })
            vim.keymap.set('n', '<leader>gw', ':Gwrite<CR>', { desc = 'Git add current file' })
            vim.keymap.set('n', '<leader>gr', ':Gread<CR>', { desc = 'Git checkout current file' })
        end,
    }
}
local opts = {}
require("lazy").setup(plugins, opts)

-- Line numbers configs 
vim.opt.number = true           
vim.opt.relativenumber = true   
vim.opt.cursorline = true       
vim.opt.cursorlineopt = 'number' 

-- Toggle line number modes with <leader>tn
vim.keymap.set('n', '<leader>tn', function()
  if vim.wo.relativenumber then
    vim.wo.relativenumber = false
    vim.wo.number = true
    print("Line numbers: absolute only")
  elseif vim.wo.number then
    vim.wo.relativenumber = false
    vim.wo.number = false
    print("Line numbers: off")
  else
    vim.wo.relativenumber = true
    vim.wo.number = true
    print("Line numbers: hybrid (relative + absolute)")
  end
end, { desc = 'Toggle line number modes' })

-- Some neotree keymaps
vim.keymap.set('n', '<C-n>', ':Neotree toggle left<CR>', { desc = 'Toggle Neotree' })
vim.keymap.set('n', '<C-e>', function()
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current_win)
  local buf_ft = vim.api.nvim_get_option_value('filetype', { buf = current_buf })

  if buf_ft == 'neo-tree' then
    vim.cmd('wincmd p')
  else
    vim.cmd('Neotree focus')
  end
end, { desc = 'Toggle focus between Neotree and file' })
vim.keymap.set('n', '<C-g>', ':Neotree float git_status<CR>', { desc = 'Show git status' })
-- neotree keymaps    
