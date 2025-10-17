local function delete_buffer()
    local bd = require('mini.bufremove').delete
    if vim.bo.modified then
        local choice = vim.fn.confirm(('Save changes to %q?'):format(vim.fn.bufname()), '&Yes\n&No\n&Cancel')
        if choice == 1 then -- Yes
            vim.cmd.write()
            bd(0)
        elseif choice == 2 then -- No
            bd(0, true)
        end
    else
        bd(0)
    end
end

local function buf_is_current(bufname)
    local realname = bufname
    if not vim.startswith(bufname, "term://") then
        realname = vim.fs.abspath(bufname)
    end

    return realname == vim.api.nvim_buf_get_name(0)
end

local function harpoon_formatted_item(index, item)
    local basename = vim.fs.basename(item.value)
    return ("%d:%s"):format(index, basename)
end

local function section_harpoon(start_index)
    local harpoon = require('harpoon')
    local len = harpoon:list():length()
    local s = ""
    for i = start_index, len do
        local item = harpoon:list():get(i)

        if buf_is_current(item.value) then
            return s, i
        end

        local spaces = "  "
        if i == start_index then
            spaces = ""
        end

        s = s .. spaces .. harpoon_formatted_item(i, item)
    end

    return s, len + 1
end

return { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
        -- Better Around/Inside textobjects
        --
        -- Examples:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [Q]uote
        --  - ci'  - [C]hange [I]nside [']quote
        require('mini.ai').setup { n_lines = 500 }

        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        require('mini.surround').setup()

        -- Simple and easy statusline.
        --  You could remove this setup call if you don't like it,
        --  and try some other statusline plugin
        local statusline = require 'mini.statusline'
        -- set use_icons to true if you have a Nerd Font
        statusline.setup {
            content = {
                active = function()
                    local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
                    local filename      = MiniStatusline.section_filename({ trunc_width = 2000,  })
                    local fileinfo      = MiniStatusline.section_fileinfo({ trunc_width = 120 })
                    local location      = MiniStatusline.section_location({ trunc_width = 75 })
                    local search        = MiniStatusline.section_searchcount({ trunc_width = 75 })

                    local harpoon = require("harpoon")

                    local hl_harpoon_inactive = 'MiniStatuslineFilename'
                    local hl_harpoon_active = 'MiniStatuslineFileinfo'
                    local harpoon_pre_active, index = section_harpoon(1)
                    local harpoon_active = ""
                    if index <= harpoon:list():length() then
                        harpoon_active = harpoon_formatted_item(index, harpoon:list():get(index))
                    end

                    local harpoon_post_active, _ = section_harpoon(index + 1)


                    return MiniStatusline.combine_groups({
                        { hl = mode_hl,                     strings = { mode } },
                        '%<', -- Mark general truncate point
                        { hl = hl_harpoon_inactive,         strings = { harpoon_pre_active } },
                        { hl = hl_harpoon_active,           strings = { harpoon_active } },
                        { hl = hl_harpoon_inactive,         strings = { harpoon_post_active } },
                        '%=', -- End left alignment
                        { hl = 'MiniStatuslineFilename',    strings = { filename } },
                        { hl = 'MiniStatuslineFileinfo',    strings = { fileinfo } },
                        { hl = mode_hl,                     strings = { search, location } },
                    })
                end
            },
            use_icons = vim.g.have_nerd_font
        }

        -- You can configure sections in the statusline by overriding their
        -- default behavior. For example, here we set the section for
        -- cursor location to LINE:COLUMN
        ---@diagnostic disable-next-line: duplicate-set-field
        statusline.section_location = function()
            return '%2l:%-2v'
        end

        -- ... and there is more!
        --  Check out: https://github.com/echasnovski/mini.nvim
    end,
    keys = {
        { '<leader>bd', delete_buffer, desc = 'Delete Buffer', },
        { '<M-x>', delete_buffer, desc = 'Delete Buffer'},
        { "<leader>bD", function() require("mini.bufremove").delete(0, true) end, desc = "Delete Buffer (Force)" },
    },
}
