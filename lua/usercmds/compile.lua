-- TODO: less scuffed compile:
-- - [X] don't try to compile with no command
-- - [X] turn this into a user command
-- - [ ] generate a location list (with trouble.nvim?) for when comp. fails
-- - [ ] only print one line at a time
-- - [ ] print compilation started... -> compilation successful/failed
-- - [ ] detect warns/errors

local function comp_fail(stderr) end

local function compile()
  vim.ui.input({ prompt = 'Compile command: ', default = vim.g.Compile_command }, function(input)
    if not input then
      return
    end

    if input == '' then
      print 'No command entered'
      return
    end

    vim.g.Compile_command = input

    local start_time = os.time()
    print 'Compilation started...'
    local cmd = vim.split(vim.g.Compile_command, ' ')
    local _, ret = pcall(vim.system, cmd, { text = true }, function(out)
      local msg = ''
      if out.stderr ~= '' then
        msg = msg .. out.stderr .. '\n'
      end

      if out.stdout ~= '' then
        msg = msg .. out.stdout .. '\n'
      end

      local time_diff = start_time - os.time()
      if out.code == 0 then
        print(msg .. ('Compilation successful (%ds)'):format(time_diff))
      else
        print(msg .. ('Compilation failed (%ds)'):format(time_diff))
        comp_fail(out.stderr)
      end
    end)

    print("Couldn't run command: " .. tostring(ret))
  end)
end

vim.api.nvim_create_user_command('Compile', compile, { nargs = 0 })
