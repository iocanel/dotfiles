-- Gitsigns
local gitsigns = require('gitsigns')
gitsigns.setup {
  signs = {
    add = { text = '│' },
    change = { text = '│' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
}

-- Neogit
local neogit = require('neogit')
neogit.setup {
  disable_signs = false,
  disable_hint = true,
  disable_commit_confirmation = true,
  auto_refresh = true,
  -- customize displayed signs
  signs = {
    -- { CLOSED, OPENED }
    section = { "", "" },
    item = { "", "" },
    hunk = { "", "" },
  },
}

-- Git Hydra
local hydra_installed, Hydra = pcall(require, "hydra")
if hydra_installed then
  local git_hint = [[
 _n_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _p_: prev hunk   _u_: undo last stage   _v_: preview hunk   _B_: blame show full 
 ^ ^              _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^              _<Enter>_: Neogit              _q_: exit
]]

  Hydra({
    name = 'Git',
    hint = git_hint,
    config = {
      buffer = bufnr,
      color = 'red',
      invoke_on_body = true,
      hint = {
	border = 'rounded'
      },
    },
    mode = {'n','x'},
    body = '<leader>gH',
    heads = {
      { 'n', "<cmd>Gitsigns next_hunk<cr>", { desc = 'next hunk', exit = false } },
      { 'p', "<cmd>Gitsigns prev_hunk<cr>", { desc = 'prev hunk', exit = false} },
      { 's', "<cmd>Gitsigns stage_hunk<cr>", { silent = true, desc = 'stage hunk' } },
      { 'u', "<cmd>Gitsigns undo_stage_hunk<cr>", { desc = 'undo last stage' } },
      { 'S', "<cmd>Gitsigns stage_buffer<cr>", { desc = 'stage buffer' } },
      { 'v', "<cmd>Gitsigns preview_hunk<cr>", { desc = 'preview hunk' } },
      { 'd', "<cmd>Gitsigns toggle_deleted<cr>", { nowait = true, desc = 'toggle deleted' } },
      { 'b', "<cmd>Gitsigns blame_line<cr>", { desc = 'blame' } },
      { '/', "<cmd>Gitsigns show<cr>", { exit = true, desc = 'show base file' } }, -- show the base of the file
      { '<Enter>', '<cmd>Neogit<cr>', { exit = true, desc = 'Neogit' } },
      { 'q', nil, { exit = true, nowait = true, desc = 'exit' } },
    }
  })
end
