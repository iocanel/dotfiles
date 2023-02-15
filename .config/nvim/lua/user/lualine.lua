--
-- [[ lualine ]]
--
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = {},
    lualine_b = {'branch' },
    lualine_c = {'filename' , 'location'},
    lualine_x = { },
    lualine_y = { },
    lualine_z = { }
  },
}
