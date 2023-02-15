local M = {};

function M:statusline_on()
  -- enable the status line
    vim.o.laststatus = 3
end

function M:statusline_off()
  -- enable the status line
    vim.o.laststatus = 0
end

function M:statusline_toggle()
  -- toggle the status line
  if vim.o.laststatus == 0 then
    M.statusline_on()
  else
    M.statusline_off()
  end
end

function M:linenumber_on()
  -- enable line numbering
    vim.wo.number = true
end

function M:linenumber_off()
  -- disable line numbering
    vim.wo.number = false
    vim.o.relativenumber = false
end

function M:relative_linenumber_on()
  -- disable relative line numbering
    vim.o.relativenumber = false
end

function M:relative_linenumber_off()
  -- disable relative line numbering
    vim.o.relativenumber = false
end

function M:linenumber_toggle()
  -- toggle line numbering and relative number on and off
  -- states: relative=on -> relative=off -> number=off
  if vim.o.relativenumber then
    M.relative_linenumber_on()
  elseif vim.wo.number then
    M.linenumber_off()
    M.relative_linenumber_off()
  else
    M.linenumber_on()
    M.relative_linenumber_on()
  end
end

function M:focus_on()
  -- enable focus mode
    vim.wo.number=false
    vim.o.relativenumber=false
    vim.o.laststatus = 0
end

function M:focus_off()
  -- disable focus mode
    vim.wo.number=true
    vim.o.relativenumber=true
    vim.o.laststatus = 3
end

function M:focus_toggle()
  -- toggle focus mode
  if vim.o.number or vim.o.laststatus > 0 then
    M.focus_on()
  else
    M.focus_off()
  end
end

return M;
