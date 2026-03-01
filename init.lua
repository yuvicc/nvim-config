vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")

-- Enable system clipboard
vim.opt.clipboard = "unnamedplus"

-- Disable arrow keys to build hjkl muscle memory
local msg = "Hey man don't use arrow keys here!"
local modes = { "n", "i", "v" }
for _, mode in ipairs(modes) do
    vim.keymap.set(mode, "<Up>", function() vim.notify(msg, vim.log.levels.WARN) end)
    vim.keymap.set(mode, "<Down>", function() vim.notify(msg, vim.log.levels.WARN) end)
    vim.keymap.set(mode, "<Left>", function() vim.notify(msg, vim.log.levels.WARN) end)
    vim.keymap.set(mode, "<Right>", function() vim.notify(msg, vim.log.levels.WARN) end)
end

require("config.lazy")
