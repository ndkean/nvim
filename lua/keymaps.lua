-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', function()
  vim.cmd 'nohl'
  require('luasnip').unlink_current()
end, { silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
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
vim.keymap.set('v', '>', '>gv', { desc = 'Indent line' })
vim.keymap.set('v', '<', '<gv', { desc = 'Uindent line' })

-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

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
