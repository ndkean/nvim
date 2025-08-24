-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', function()
  vim.cmd 'nohl'
  require('luasnip').unlink_current()
end, { silent = true })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>tn', function()
  vim.o.number = not vim.o.number
end, { desc = '[T]oggle line [n]umber' })
vim.keymap.set('n', '<leader>tr', function()
  vim.o.relativenumber = not vim.o.relativenumber
end, { desc = '[T]oggle [r]elative number' })

vim.keymap.set('v', '<leader>y', '"+y', { desc = 'Yank to system clipboard' })

vim.keymap.set('x', '<leader>p', '"_dP', { desc = 'Paste without yanking' })

vim.keymap.set('v', '<leader>d', '"_d', { desc = 'Delete without yanking' })
vim.keymap.set('n', '<leader>d', '"_d', { desc = 'Delete without yanking' })

vim.keymap.set('v', '>', '>gv', { desc = 'Indent line' })
vim.keymap.set('v', '<', '<gv', { desc = 'Unindent line' })

vim.keymap.set('n', '<A-k>', '<C-Y>k', { desc = 'Scroll up one line' })
vim.keymap.set('n', '<A-j>', '<C-E>j', { desc = 'Scroll down one line' })

vim.keymap.set('v', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
vim.keymap.set('v', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })

-- TODO: less scuffed compile:
-- - [ ] don't try to compile with no command
-- - [ ] turn this into a user command
-- - [ ] generate a location list (with trouble.nvim?) for when comp. fails
-- - [ ] only print one line at a time
-- - [ ] print compilation started... -> compilation successful/failed
-- - [ ] detect warns/errors
vim.keymap.set('n', '<C-c>', function()
  vim.ui.input({ prompt = 'Compile command: ', default = vim.g.Compile_command }, function(input)
    if not input then
      return
    end

    vim.g.Compile_command = input

    local cmd = vim.split(vim.g.Compile_command, ' ')
    vim.system(cmd, { text = true }, function(out)
      local msg = ''
      if out.stderr ~= '' then
        msg = msg .. out.stderr .. '\n'
      end

      if out.stdout ~= '' then
        msg = msg .. out.stdout .. '\n'
      end

      if out.code == 0 then
        print(msg .. 'Compilation successful')
      else
        print(msg .. 'Compilation failed')
      end
    end)
  end)
end, { desc = '[C]ompile' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set('n', '<C-S-h>', '<C-w>H', { desc = 'Move window to the left' })
-- vim.keymap.set('n', '<C-S-l>', '<C-w>L', { desc = 'Move window to the right' })
-- vim.keymap.set('n', '<C-S-j>', '<C-w>J', { desc = 'Move window to the lower' })
-- vim.keymap.set('n', '<C-S-k>', '<C-w>K', { desc = 'Move window to the upper' })
