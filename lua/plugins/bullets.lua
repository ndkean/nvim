return { 
    "bullets-vim/bullets.vim",
    config = function()
        vim.keymap.set('n', '<C-Space>', vim.cmd.ToggleCheckbox, { desc = 'ToggleCheckbox '})
    end
}
