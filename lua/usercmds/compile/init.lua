-- TODO: less scuffed compile:
-- - [X] let user stop compilation
-- - [ ] properly parse the commands (dont split spaces in quotes)
-- - [ ] do something with stdout when compilation succeeds.. e.g. display it in a read only buffer
-- - [ ] odin error parser
-- - [ ] make it a plugin so i can use trouble as a dep
-- - [ ] use the builtin jumplist if trouble not available

local util = require 'util'

---@param item trouble.Item
local function item_id(item)
    return item.filename .. ':' .. util.dump(item.pos) .. ':' .. item.item.message
end

---@class compile.ErrorItem
---@field path       string
---@field pos        integer
---@field severity?  string
---@field message?   string

---@param items compile.ErrorItem[]
local function create_jumplist(items)
    local source = require 'usercmds.compile.trouble_source'
    local Item = require 'trouble.item'

    source.items = {}
    local set = {}
    for _, err_item in ipairs(items) do
        local item = Item.new {
            source = 'compile',
            filename = err_item.path,
            pos = err_item.pos,
            item = err_item,
        }

        item.id = item_id(item)
        if not set[item.id] then
            set[item.id] = true
            table.insert(source.items, item)
        end
    end

    local opts = { mode = 'comp_failure' }
    require('trouble').open(opts)
end

---@param line string
---@return compile.ErrorItem?
local function get_compiler_errors_clang(line)
    local path, line_no, col, severity, msg = string.match(line, '^(.-):(%d+):(%d+): (%a+): (.-)$')
    if path == nil then
        return nil
    end

    severity = string.upper(severity)
    if severity == 'NOTE' then
        severity = 'HINT'
    end

    return {
        path = path,
        pos = { line_no, col - 1 },
        severity = vim.diagnostic.severity[severity],
        message = msg,
    }
end

local function get_compiler_errors_odin(line)
    local path, line_no, col, severity, msg = string.match(line, '^(.-)%((%d+):(%d+)%) ([%a%s]+): (.-)$')
    if path == nil then
        return nil
    end

    severity = string.upper(severity)
    if severity == 'SYNTAX ERROR' then
        severity = 'ERROR'
    end

    return {
        path = path,
        pos = { line_no, col - 1 },
        severity = vim.diagnostic.severity[severity],
        message = msg,
    }
end

local OUTPUT_PARSERS = {
    get_compiler_errors_clang,
    get_compiler_errors_odin,
}

local function comp_fail(stderr)
    local errors = {}
    for _, line in ipairs(vim.split(stderr, '\n')) do
        for _, parser in ipairs(OUTPUT_PARSERS) do
            local result = parser(line)
            if result then
                table.insert(errors, result)
                break
            end
        end
    end

    if #errors > 0 then
        create_jumplist(errors)
    end
end

local compile_proc
local SIGINT = 2

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
        local cmd = vim.split(vim.g.Compile_command, ' ') -- TODO: need to do this properly
        local _, ret = pcall(vim.system, cmd, { text = true }, function(out)
            if out.signal == SIGINT then return end

            if out.code == 0 then
                local time_diff = os.time() - start_time
                local time_diff_string = ('(%ss)'):format(time_diff > 0 and time_diff or '<1')
                print('Compilation successful ' .. time_diff_string)
                vim.schedule(function()
                    require('trouble').close { source = 'compile' }
                end)
            else
                print 'Compilation failed'
                vim.schedule(function()
                    comp_fail(out.stderr)
                end)
            end
        end)

        if type(ret) == 'string' then
            print("Couldn't run command: " .. ret)
            return
        end

        compile_proc = ret
    end)
end

local function kill_compile()
    if compile_proc == nil then
        print("No compilation running")
        return
    end

    compile_proc:kill(SIGINT)
    print("Compilation killed")
    compile_proc = nil
end

vim.api.nvim_create_user_command('Compile', compile, { nargs = 0 })
vim.api.nvim_create_user_command('CompileKill', kill_compile, { nargs = 0 })
