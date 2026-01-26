local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
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
            vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
        end,
    },
    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "cpp", "c", "java", "rust", "python", "bash" },
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
        config = function()
            require("neo-tree").setup({
                filesystem = {
                    filtered_items = {
                        visible = false,      -- Hidden files not visible by default
                        hide_dotfiles = true, -- Hide dotfiles by default
                        hide_gitignored = false,
                    },
                },
                window = {
                    mappings = {
                        ["H"] = "toggle_hidden",
                    },
                },
            })
        end,
    },
    {
        "mason-org/mason.nvim",
        opts = {}
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = { "clangd" },
        }
    },
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip",
        },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'luasnip' },
                    { name = 'buffer' },
                    { name = 'path' },
                }),
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "mason-org/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            vim.lsp.config('*', {
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders",
                },
                filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
                root_markers = { ".clangd", ".clang-tidy", ".clang-format", "compile_commands.json", "compile_flags.txt", ".git" },
                capabilities = capabilities,
            })

            vim.lsp.enable('clangd')
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'Hover documentation' })
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = 'Go to implementation' })
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = 'Rename symbol' })
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = 'Code action' })
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, { desc = 'Find references' })
        end,
    },
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        opts = {
            formatters_by_ft = {
                cpp = { "clang_format" },
                c = { "clang_format" },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        },
        config = function(_, opts)
            require("conform").setup(opts)

            -- Manual clang format
            vim.keymap.set('n', '<leader>fm', function()
                require("conform").format({ async = true, lsp_fallback = true })
            end, { desc = 'Format buffer' })
        end,
    },
    {
        'jeffkreeftmeijer/vim-numbertoggle',
    },
    {
        'tpope/vim-fugitive',
        config = function()
            -- Git fugitive keymaps for common git operations
            vim.keymap.set('n', '<leader>gs', ':Git<CR>', { desc = 'Git status' })
            vim.keymap.set('n', '<leader>gc', ':Git commit<CR>', { desc = 'Git commit' })
            vim.keymap.set('n', '<leader>gp', ':Git push<CR>', { desc = 'Git push' })
            vim.keymap.set('n', '<leader>gu', ':Git pull<CR>', { desc = 'Git pull' })
            vim.keymap.set('n', '<leader>gl', ':Git log<CR>', { desc = 'Git log' })
            vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { desc = 'Git blame' })
            vim.keymap.set('n', '<leader>gd', ':Gdiffsplit<CR>', { desc = 'Git diff split' })
            vim.keymap.set('n', '<leader>gw', ':Gwrite<CR>', { desc = 'Git add current file' })
            vim.keymap.set('n', '<leader>gr', ':Gread<CR>', { desc = 'Git checkout current file' })
        end,
    },
    {
        'akinsho/bufferline.nvim',
        version = "*",
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require("bufferline").setup({
                options = {
                    mode = "buffers",
                    offsets = {
                        {
                            filetype = "neo-tree",
                            text = "File Explorer",
                            highlight = "Directory",
                            separator = true
                        }
                    },
                }
            })
            -- Keymaps for buffer navigation
            vim.keymap.set('n', '<Tab>', ':BufferLineCycleNext<CR>', { desc = 'Next buffer', silent = true })
            vim.keymap.set('n', '<S-Tab>', ':BufferLineCyclePrev<CR>', { desc = 'Previous buffer', silent = true })
            vim.keymap.set('n', '<leader>bd', ':bdelete<CR>', { desc = 'Close buffer', silent = true })
            vim.keymap.set('n', '<leader>bp', ':BufferLinePick<CR>', { desc = 'Pick buffer', silent = true })
        end,
    },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require("toggleterm").setup({
                size = 15,
                open_mapping = [[<C-\>]],
                direction = 'horizontal',
                shade_terminals = true,
                start_in_insert = true,
                persist_size = true,
                close_on_exit = true,
            })
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

-- code snippets directory
local template_dir = vim.fn.stdpath("config") .. "/templates/"
local function insert_template(template_file)
    local file_path = template_dir .. template_file
    if vim.fn.filereadable(file_path) == 1 then
        vim.cmd("0read " .. file_path)
        vim.cmd("normal! Gdd")
    else
        print("Template not found: " .. file_path)
    end
end

-- keymaps for different code snippets
vim.keymap.set('n', '<leader>cp', function() insert_template('cp_template.cpp') end,
    { desc = 'Insert competitive programming template' })

-- Terminal keymaps using toggleterm
vim.keymap.set('n', '<leader>tt', ':ToggleTerm direction=horizontal<CR>', { desc = 'Toggle terminal at bottom' })
vim.keymap.set('n', '<leader>tf', ':ToggleTerm direction=float<CR>', { desc = 'Toggle floating terminal' })
vim.keymap.set('n', '<leader>tv', ':ToggleTerm direction=vertical<CR>', { desc = 'Toggle vertical terminal' })
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { desc = 'Exit terminal mode' })
vim.keymap.set('t', '<C-\\>', [[<C-\><C-n>:ToggleTerm<CR>]], { desc = 'Close terminal' })

-- C++ build commands
vim.keymap.set('n', '<C-b>', function()
    local file = vim.fn.expand('%')
    local output = vim.fn.expand('%:r')
    vim.cmd('split | terminal g++ -std=c++23 -Wall -o ' .. output .. ' ' .. file)
end, { desc = 'Compile cpp file' })

-- Compile and run cpp program
vim.keymap.set('n', '<C-r>', function()
    local file = vim.fn.expand('%')
    local output = vim.fn.expand('%:r')
    vim.cmd('split | terminal g++ -std=c++23 -Wall -o ' .. output .. ' ' .. file .. ' && ./' .. output)
end, { desc = 'Compile and run cpp file' })
