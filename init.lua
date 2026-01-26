vim.cmd("set expandtab")
vim.cmd("set tabstop=4")
vim.cmd("set softtabstop=4")
vim.cmd("set shiftwidth=4")

-- Enable system clipboard
vim.opt.clipboard = "unnamedplus"

require("config.lazy")
