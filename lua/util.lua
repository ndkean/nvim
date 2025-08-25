local M = {}

function M.dump(o)
  if type(o) == 'table' then
    if next(o) == nil then
      return '{ }'
    end

    local s = '{ '
    for k, v in pairs(o) do
      s = s .. '[' .. M.dump(k) .. ']=' .. M.dump(v) .. ', '
    end
    return s:sub(0, #s - 2) .. ' }'
  elseif type(o) == 'string' then
    return "'" .. o .. "'"
  else
    return tostring(o)
  end
end

function M.file_exists(name)
  local f = io.open(name, 'r')
  if f ~= nil then
    io.close(f)
    return true
  end
  return false
end

function M.basename(filename)
  for i = #filename, 1, -1 do
    local c = filename:sub(i, i)
    if c == '/' then
      return filename:sub(i + 1)
    end
  end
  return filename
end

function M.dirname(path)
  for i = #path, 1, -1 do
    local c = path:sub(i, i)
    if c == '/' then
      return path:sub(0, i)
    end
  end
  return '.'
end

return M
