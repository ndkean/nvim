local file_exists = require('util').file_exists

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- vim.api.nvim_create_autocmd('BufEnter', {
--   pattern = '*.lua',
--   callback = function()
--     vim.o.expandtab = true
--     vim.o.tabstop = 2
--     vim.o.shiftwidth = 2
--   end,
-- })

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = { '*.c', '*.cpp', '*.h', '*.hpp' },
  callback = function(ev)
    vim.keymap.set('n', '<leader>h', function()
      local file_path
      local stripped_file
      local is_impl = true
      if vim.endswith(ev.file, '.c') then
        stripped_file = ev.file:sub(1, - #'.c')
      elseif vim.endswith(ev.file, '.cpp') then
        stripped_file = ev.file:sub(1, - #'.cpp')
      elseif vim.endswith(ev.file, '.h') then
        stripped_file = ev.file:sub(1, - #'.h')
        is_impl = false
      elseif vim.endswith(ev.file, '.hpp') then
        stripped_file = ev.file:sub(1, - #'.hpp')
        is_impl = false
      end

      if is_impl then
        if file_exists(stripped_file .. 'h') then
          file_path = stripped_file .. 'h'
        elseif file_exists(stripped_file .. 'hpp') then
          file_path = stripped_file .. 'hpp'
        else
          print 'No corresponding h/hpp file found'
          return
        end
      else
        if file_exists(stripped_file .. 'c') then
          file_path = stripped_file .. 'c'
        elseif file_exists(stripped_file .. 'cpp') then
          file_path = stripped_file .. 'cpp'
        else
          print 'No corresponding c/cpp file found'
          return
        end
      end

      vim.cmd.e(file_path)
    end, { buffer = true, desc = 'Toggle H/HPP and C/CPP file' })
  end,
})
