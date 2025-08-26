return {
  'vimwiki/vimwiki',
  event = 'BufEnter *.wiki',
  keys = {
    { '<leader>ww',         vim.cmd.VimwikiIndex,                  desc = 'Open index' },
    { '<leader>wi',         vim.cmd.VimwikiDiaryIndex,             desc = 'Open diary index' },
    { '<leader>wt',         vim.cmd.VimwikiTabIndex,               desc = 'Open index in new tab' },
    { '<leader>ws',         vim.cmd.VimwikiUISelect,               desc = 'Display wiki selection' },
    { '<leader>w<leader>i', vim.cmd.VimwikiDiaryGenerateLinks,     desc = 'New diary section' },
    { '<leader>w<leader>t', vim.cmd.VimwikiTabMakeDiaryNote,       desc = 'Open today\'s diary in new tab' },
    { '<leader>w<leader>y', vim.cmd.VimwikiMakeYesterdayDiaryNote, desc = 'Make yesterday\'s diary note' },
    { '<leader>w<leader>m', vim.cmd.VimwikiMakeTomorrowDiaryNote,  desc = 'Make tomorrow\'s diary note' },
    { '<leader>w<leader>w', vim.cmd.VimwikiMakeDiaryNote,          desc = 'Make today\'s diary note' },
  }
}
