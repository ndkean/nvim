return {
  'leath-dub/snipe.nvim',
  keys = {
    {
      '<leader><leader>',
      function()
        require('snipe').open_buffer_menu()
      end,
      desc = 'Open Snipe buffer menu',
    },
  },
  opts = {
    ui = {
      max_height = 9,
    },
    hints = {
      dictionary = '123456789',
    },
  },
}
