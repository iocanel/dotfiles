require('user.plugins')
require('user.options')
require('user.treesitter')
require('user.lsp.init')
require('user.telescope')
require('user.toggleterm')
require('user.lualine')
require('user.cmp')
require('user.git')
require('user.keymaps')
require('user.whichkey')

--local jdtls = require('user.lsp.jdtls')
local editor = require('user.editor')

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})


-- Enable Comment.nvim
require('Comment').setup()

-- Enable `lukas-reineke/indent-blankline.nvim`
-- See `:help indent_blankline.txt`
require('indent_blankline').setup {
  char = '┊',
  show_trailing_blankline_indent = false,
}

-- finalize startup
-- jdtls.setup()
editor.statusline_off()
editor.linenumber_off()



-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
