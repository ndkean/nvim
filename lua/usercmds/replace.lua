vim.api.nvim_create_user_command('ReplaceWord', function(_)
    local word = vim.fn.expand('<cword>')
    local search_arg = "\\<" .. word .. "\\>"
    local range
    local mode = vim.api.nvim_get_mode().mode
    if mode == "n" then
        range = "%"
    else
        range = "'<,'>"
    end

    vim.ui.input({ prompt = ("Replace `%s` with what: "):format(word) }, function(input)
        if not input then
            return
        end

        local what = input

        vim.cmd(("%ss/%s/%s/gc"):format(range, search_arg, what))
    end)
end, { nargs = 0 })
