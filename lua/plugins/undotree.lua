return {
  'mbbill/undotree',
  event = 'BufEnter',
  keys = {
    {
      '<leader>U',
      vim.cmd.UndotreeToggle,
      desc = '[U]ndotree: Toggle',
    },
  },
}
