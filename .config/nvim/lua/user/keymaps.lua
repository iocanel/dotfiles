--
-- [[ General ]]
--
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

--
-- [[ Open ]]
--
vim.keymap.set('n', '<leader>of', "<cmd>Telescope find_files<cr>", { desc = 'open files' })
vim.keymap.set('n', '<leader><space>', "<cmd>Telescope find_files<cr>", { desc = 'open files' })
vim.keymap.set('n', '<leader>ob', "<cmd>Telescope buffers<cr>", { desc = 'open buffer' })
vim.keymap.set('n', '<leader>or', "<cmd>Telescope repo<cr>", { desc = 'open repository' })
vim.keymap.set('n', '<leader>oR', "<cmd>Telescope oldfiles<cr>", { desc = 'open recent' })
-- Zoxide
vim.keymap.set('n', '<leader>od', "<cmd>Telescope zoxide list<cr>", { desc = 'open directory' })
-- ToggleTerm
vim.keymap.set('n', '<leader>ot', "<cmd>ToggleTerm<cr>", { desc = 'open terminal' })

--
-- [[ Search ]]
--
vim.keymap.set('n', '<leader>sf', "<cmd>Telescope find_files<cr>", { desc = 'search files' })
vim.keymap.set('n', '<leader>sh', "<cmd>Telescope help_tags<cr>", { desc = 'search help' })
vim.keymap.set('n', '<leader>sw', "<cmd>Telescope grep_string<cr>", { desc = 'search current word' })
vim.keymap.set('n', '<leader>sg', "<cmd>Telescope live_grep<cr>", { desc = 'search grep' })
vim.keymap.set('n', '<leader>sd', "<cmd>Telescope diagnostics<cr>", { desc = 'search diagnostics' })
vim.keymap.set('n', '<leader>sb', function()
  require('telescope_builtin').current_buffer_fuzzy_find(require('telescope_themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = 'search buffer]' })

--
-- [[ Window ]]
--
vim.keymap.set('n', '<leader>wsh', "<cmd>horizonal_split<cr>", { desc = 'window split horizontally' })
vim.keymap.set('n', '<leader>wsv', "<cmd>vertical_split<cr>", { desc = 'window split vertically' })
vim.keymap.set('n', '<leader>wjh', "<C-w>h", { desc = 'window jump horizontally' })
vim.keymap.set('n', '<leader>wjv', "<C-w>v", { desc = 'window jump vertically' })

--
-- [[ Git ]]
--
vim.keymap.set('n', '<leader>gc', "<cmd>Git commit<cr>", { desc = 'git commit' })
-- Gitsigns
vim.keymap.set('n', '<leader>gs', "<cmd>Gitsigns stage_buffer<cr>", { desc = 'git stage buffer' })
vim.keymap.set('n', '<leader>ghn', "<cmd>Gitsigns next_hunk<cr>", { desc = 'git hunk pext' })
vim.keymap.set('n', '<leader>ghp', "<cmd>Gitsigns prev_hunk<cr>", { desc = 'git hunk previous' })
vim.keymap.set('n', '<leader>ghs', "<cmd>Gitsigns stage_hunk<cr>", { desc = 'git hunk stage' })
vim.keymap.set('n', '<leader>ghu', "<cmd>Gitsigns undo_stage_hunk<cr>", { desc = 'git hunk uundo stage' })
vim.keymap.set('n', '<leader>ghr', "<cmd>Gitsigns reset_hunk<cr>", { desc = 'git hunk reset' })
vim.keymap.set('n', '<leader>ghv', "<cmd>Gitsigns preview_hunk<cr>", { desc = 'git hunk preview' })
-- Neogit
vim.keymap.set('n', '<leader>gn', "<cmd>Neogit<cr>", { desc = 'neogit' })

--
-- [[ Editor ]]
--
local editor = require("user.editor")
vim.keymap.set('n', '<leader>es', editor.statusline_toggle, { desc = 'status line toggle' })
vim.keymap.set('n', '<leader>en', editor.linenumber_toggle, { desc = 'line number toggle' })
vim.keymap.set('n', '<leader>ef', editor.focus_toggle, { desc = 'focus mode toggle' })

--
-- [[ Diagnostic keymaps ]]
--
vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev)
vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>df', vim.diagnostic.open_float)
vim.keymap.set('n', '<leader>ds', vim.diagnostic.setloclist)


--
-- [[ LSP ]]
--
function setup_lsp_bindindgs()
  vim.keymap.set('n', '<leader>lrn', vim.lsp.buf.rename, { desc = 'rename'})
  vim.keymap.set('n', '<leader>lca', vim.lsp.buf.code_action, { desc = 'code action'})

  vim.keymap.set('n', 'lgd', vim.lsp.buf.definition, { desc = 'goto definition'})
  vim.keymap.set('n', 'lgr', require('telescope.builtin').lsp_references, { desc = 'goto references'})
  vim.keymap.set('n', 'lgi', vim.lsp.buf.implementation, { desc = 'goto implementation'})
  vim.keymap.set('n', '<leader>ltd', vim.lsp.buf.type_definition, { desc = 'type definition'})
  vim.keymap.set('n', '<leader>lsd', require('telescope.builtin').lsp_document_symbols, { desc = 'document symbols'})
  vim.keymap.set('n', '<leader>lsw', require('telescope.builtin').lsp_dynamic_workspace_symbols, { desc = 'workspace symbols'})
end

function setup_coc_bindings()
  vim.keymap.set('n', '<leader>lrn', '<Plug>(coc-refactor)', { desc = 'rename'})
  vim.keymap.set('x', '<leader>lrn', '<Plug>(coc-refactor-selected)', { desc = 'rename'})
  vim.keymap.set('n', '<leader>lca', '<Plug>(coc-codeaction)', { desc = 'code action'})
  vim.keymap.set('x', '<leader>lca', '<Plug>(coc-codeaction-selected)', { desc = 'code action'})

  vim.keymap.set('n', 'lgd', '<Plug>(coc-definition)', { desc = 'goto definition'})
  vim.keymap.set('n', 'lgr', '<Plug>(coc-references)', { desc = 'goto references'})
  vim.keymap.set('n', 'lgi', '<Plug>(coc-implementation)', { desc = 'goto implementation'})
  vim.keymap.set('n', '<leader>ltd', '<Plug>(coc-type-definition)', { desc = 'type definition'})
end


-- See `:help K` for why this keymap
vim.keymap.set('n', 'ldh', vim.lsp.buf.hover, { desc = 'hover documentation'})
vim.keymap.set('n', 'lds', vim.lsp.buf.signature_help, { desc = 'signature documentation'})

-- Lesser used LSP functionality
vim.keymap.set('n', 'lgD', vim.lsp.buf.declaration, { desc = 'goto declaration'})
vim.keymap.set('n', '<leader>lwa', vim.lsp.buf.add_workspace_folder, { desc = 'workspace add folder'})
vim.keymap.set('n', '<leader>lwr', vim.lsp.buf.remove_workspace_folder, { desc = 'workspace remove folder'})
vim.keymap.set('n', '<leader>lwl', function()
  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
end, { desc = 'workspace list folders'})

-- [Optional] if which-key is installed register categories
local which_key_installed, which_key = pcall(require, 'which-key')
if which_key_installed then
  which_key.register({ -- mappings 
    e = {
      name = "editor",
    },
    d= {
      name = "diagnostics",
    },
    g = {
      name = "git",
      h = {
        name = "hunk",
      },
    },
    h = {
      name = "help",
    },
    l = {
      name = "lsp",
    },
    s = {
      name = "search",
    },
    o = {
      name = "open",
    },
    w = {
      name = "window",
      s = {
        name = "window split",
      },
      j = {
        name = "window jump",
      },
    },
  },
    { -- opts
      mode = "n", -- NORMAL mode
      prefix = " ",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = false, -- use `nowait` when creating keymaps
    })
end

setup_lsp_bindindgs()

-- [Optional] use coc bindings for .java files if coc-java is installed
local coc_installed, _ = pcall(require, 'coc-java')
if coc_installed then
  vim.cmd('autocmd FileType java lua setup_coc_bindings()')
end
