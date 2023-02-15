-- [[ Telescope ]]
local telescope = require('telescope')
telescope.setup {
  defaults = {
    mappings = {
      i = {
	['<C-u>'] = false,
	['<C-d>'] = false,
      },
    },
  },
}


-- Telescope extensions
pcall(telescope.load_extension, 'fzf')
pcall(telescope.load_extension, 'zoxide')

local repo_ext_installed, repo = pcall(telescope.load_extension, 'repo')
if repo_ext_installed then
  telescope.setup {
    extensions = {
      repo = {
	list = {
	  fd_opts = {
	    "--no-ignore-vcs",
	  },
	  search_dirs = {
	    "~/workspace",
	  },
	},
      },
    },
  }
end
