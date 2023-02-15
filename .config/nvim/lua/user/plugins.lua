-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.system { 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path }
  vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)

  -- Package manager
  use 'wbthomason/packer.nvim'

  use { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
   -- commit = "0eecf453d33248e9d571ad26559f35175c37502d",
    requires = {
      -- Automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Useful status updates for LSP
      'j-hui/fidget.nvim',

      -- Additional lua configuration, makes nvim stuff amazing
      'folke/neodev.nvim',
    },
  }

--  use { 'mfussenegger/nvim-jdtls' }

  use {'neoclide/coc.nvim', branch = 'release'}
  use {'neoclide/coc-java', tag = '1.14.1'}

  use { -- Autocompletion
    'hrsh7th/nvim-cmp',
    commit = "11a95792a5be0f5a40bab5fc5b670e5b1399a939",
    requires = { 'hrsh7th/cmp-nvim-lsp', 'L3MON4D3/LuaSnip', 'saadparwaiz1/cmp_luasnip' },
  }

  use { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
		commit = "8e763332b7bf7b3a426fd8707b7f5aa85823a5ac",
    run = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
  }

  use { -- Additional text objects via treesitter
    'nvim-treesitter/nvim-treesitter-textobjects',
    commit="2fb97bd6c53d78517d2022a0b84422c18ce5686e",
    after = 'nvim-treesitter',
  }

  -- Git related plugins
  use { 'tpope/vim-fugitive', commit="2febbe1f00be04f16daa6464cb39214a8566ec4b" }
  use { 'tpope/vim-rhubarb', commit="cad60fe382f3f501bbb28e113dfe8c0de6e77c75" }
	use { "lewis6991/gitsigns.nvim", commit = "2c6f96dda47e55fa07052ce2e2141e8367cbaaf2" }
	use { "TimUntersberger/neogit", commit = "089d388876a535032ac6a3f80e19420f09e4ddda" }

  use { "norcalli/nvim-colorizer.lua" }
  use { 'NTBBloodbath/doom-one.nvim'}
  use { "nekonako/xresources-nvim", commit = "745b4df924a6c4a7d8026a3fb3a7fa5f78e6f582" }
  use { 'nvim-lualine/lualine.nvim', commit = "0050b308552e45f7128f399886c86afefc3eb988" }-- Fancier statusline
  use { 'lukas-reineke/indent-blankline.nvim', commit = "c4c203c3e8a595bc333abaf168fcb10c13ed5fb7" } -- Add indentation guides even on blank lines
  use { 'numToStr/Comment.nvim', commit = "eab2c83a0207369900e92783f56990808082eac2" } -- "gc" to comment visual regions/lines
  use { 'tpope/vim-sleuth', commit = "1cc4557420f215d02c4d2645a748a816c220e99b" } -- Detect tabstop and shiftwidth automatically

  -- Fuzzy Finder (files, lsp, etc)
  use { 'nvim-telescope/telescope.nvim', commit = '2f32775405f6706348b71d0bb8a15a22852a61e4', requires = { 'nvim-lua/plenary.nvim' } }

  -- Fuzzy Finder Algorithm which requires local dependencies to be built. Only load if `make` is available
  use { 'nvim-telescope/telescope-fzf-native.nvim', commit = "fab3e2212e206f4f8b3bbaa656e129443c9b802e", run = 'make', cond = vim.fn.executable 'make' == 1 }

  use { "cljoly/telescope-repo.nvim", commit = "92598143f8c4cadb47f5aef3f7775932827df8f2" }

	use { "jvgrootveld/telescope-zoxide", commit = "856af0d83d2e167b5efa080567456c1578647abe" }

  -- WhichKey
  use { "folke/which-key.nvim", commit="e4fa445065a2bb0bbc3cca85346b67817f28e83e" }

  use { "nvim-pack/nvim-spectre", commit = "24275beae382e6bd0180b3064cf5729548641a02" }

  -- Toggle term
  use { "akinsho/toggleterm.nvim", commit = "2a787c426ef00cb3488c11b14f5dcf892bbd0bda" }

  -- Hydra
  use { "anuvyklack/hydra.nvim", commit = "d00274f05363c13f29ed1fa571026a066a634cce" }

  -- Add custom plugins to packer from ~/.config/nvim/lua/custom/plugins.lua
  local has_plugins, plugins = pcall(require, 'custom.plugins')
  if has_plugins then
    plugins(use)
  end

  if is_bootstrap then
    require('packer').sync()
  end
end)

-- When we are bootstrapping a configuration, it doesn't
-- make sense to execute the rest of the init.lua.
--
-- You'll need to restart nvim, and then it will work.
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end

-- Automatically source and re-compile packer whenever you save this init.lua
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  command = 'source <afile> | silent! LspStop | silent! LspStart | PackerCompile',
  group = packer_group,
  pattern = vim.fn.expand '$MYVIMRC',
})


-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup init_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])
