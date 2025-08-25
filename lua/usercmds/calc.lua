local dump = require('util').dump

local operators = {
  [','] = { 1, 2 },
  ['+'] = { 3, 4 },
  ['-'] = { 3, 4 },
  ['*'] = { 5, 6 },
  ['/'] = { 5, 6 },
  ['%'] = { 5, 6 },
  ['^'] = { 9, 10 },
}

local prefix_ops = {
  ['+'] = 7,
  ['-'] = 7,
}

local postfix_ops = {
  ['!'] = 11,
}

local functions = {
  ['sin'] = {fun = math.sin, nargs = 1},
  ['cos'] = {fun = math.cos, nargs = 1},
  ['tan'] = {fun = math.tan, nargs = 1},
  ['asin'] = {fun = math.asin, nargs = 1},
  ['acos'] = {fun = math.acos, nargs = 1},
  ['atan'] = {fun = math.atan, nargs = 1},
  ['atan2'] = {fun = math.atan2, nargs = 2},
  ['sqrt'] = {fun = math.sqrt, nargs = 1},
  ['log'] = {fun = math.log10, nargs = 1},
  ['log2'] = {fun = function(x) return math.log(x, 2) end, nargs = 1},
  ['ln'] = {fun = math.log, nargs = 1},
  ['logn'] = {fun = math.log, nargs = 2},
  ['abs'] = {fun = math.abs, nargs = 1},
}

local h2b = {
['0']='0000', ['1']='0001', ['2']='0010', ['3']='0011',
['4']='0100', ['5']='0101', ['6']='0110', ['7']='0111',
['8']='1000', ['9']='1001', ['A']='1010', ['B']='1011',
['C']='1100', ['D']='1101', ['E']='1110', ['F']='1111'
}
local function hex2bin(n)
  return n:upper():gsub(".", h2b)
end
local function dec2bin(n)
  return hex2bin(string.format("%X", n))
end

local function tokens_peek(tokens)
  return tokens.tokens[tokens.i]
end

local function tokens_next(tokens)
  local result = tokens_peek(tokens)
  tokens.i = tokens.i + 1
  return result
end

local function tokenize(args)
  local tokens = {}
  for _, arg in ipairs(args) do
    local i = 1
    while i <= #arg do
      local c = arg:sub(i, i)
      if string.match(c, "%d") or c == '.' then
        local start_index = i
        local dec_point_found = c == '.'
        i = i + 1
        c = arg:sub(i, i)
        while string.match(c, "%d") or c == '.' do
          if c == '.' and dec_point_found then
            print('Extra \'.\' inside digit')
            return
          end
          dec_point_found = c == '.'

          i = i + 1
          c = arg:sub(i, i)
        end
        i = i - 1
        local num = tonumber(arg:sub(start_index, i))
        assert(num)
        table.insert(tokens, { kind = 'number', val = num })
      elseif operators[c] or prefix_ops[c] or postfix_ops[c] then
        table.insert(tokens, { kind = 'operator', val = c })
      elseif c == '(' then
        table.insert(tokens, { kind = '(', val = c })
      elseif c == ')' then
        table.insert(tokens, { kind = ')', val = c })
      elseif string.match(c, "%a") then
        local start_index = i
        i = i + 1
        while string.match(arg:sub(i, i), "%w") do
          i = i + 1
        end
        i = i - 1
        local str = string.sub(arg, start_index, i):lower()
        if not functions[str] then
          print("Not a function: " .. str)
          return
        end
        table.insert(tokens, { kind = 'function', val = str })
      else
        print('Invalid character: ' .. c)
        return
      end
      i = i + 1
    end
  end

  return { i = 1, tokens = tokens }
end

local function factorial_unchecked(number)
  if number == 0 then
    return 1
  else
    return number * factorial_unchecked(number - 1)
  end
end

local function factorial(number)
  if math.floor(number) ~= number then
    print 'Factorial not valid for non-integer numbers'
    return nil
  elseif number < 0 then
    print 'Factorial not valid for negative numbers'
    return nil
  else
    return factorial_unchecked(number)
  end
end

local function eval_binary(operator, left, right)
    assert(operator)
    assert(left)
    assert(right)

    if operator == '+' then
      return left + right
    elseif operator == '-' then
      return left - right
    elseif operator == '*' then
      return left * right
    elseif operator == '/' then
      return left / right
    elseif operator == '^' then
      return left ^ right
    elseif operator == '%' then
      return left % right
    elseif operator == ',' then
      local t = {}
      if type(left) == 'number' then
        table.insert(t, left)
      else
        for _, val in ipairs(left) do
          table.insert(t, val)
        end
      end

      if type(right) == 'number' then
        table.insert(t, right)
      else
        for _, val in ipairs(right) do
          table.insert(t, val)
        end
      end

      return t
    else
      assert(false, 'Binary operator not handled: ' .. operator)
      return nil
    end
end

local function eval_unary(operator, operand)
    assert(operator)
    assert(operand)

    if operator == '+' then
      return operand
    elseif operator == '-' then
      return -operand
    elseif operator == '!' then
      return factorial(operand)
    else
      assert(false, 'Unary operator not handled: ' .. operator)
    end
end

local function evaluate_prec(tokens, min_prec, flags)
  if not flags then
    flags = {}
  end

  local lhs = tokens_next(tokens)
  if not lhs then
    print 'Unexpected end of expression'
    return
  elseif lhs.kind == 'number' then
    lhs = lhs.val
  elseif lhs.kind == 'operator' then
    if lhs.val == ',' and not flags.inside_func then
      print('Unexpected comma outside of function arguments')
      return
    end

    local prec = prefix_ops[lhs.val]
    if not prec then
      print('Unexpected operator: ', lhs.val)
      return
    end

    local rhs = evaluate_prec(tokens, prec, flags)
    lhs = eval_unary(lhs.val, rhs)
    if not lhs then
      return
    end
  elseif lhs.kind == '(' then
    lhs = evaluate_prec(tokens, 0, flags)
    if tokens_next(tokens).kind ~= ')' then
      print 'Mismatched parentheses'
      return
    end
  elseif lhs.kind == 'function' then
    local fun = functions[lhs.val]
    flags.inside_func = true
    local args = evaluate_prec(tokens, 0, flags)
    if type(args) == 'number' then
      args = {args}
    end

    assert(type(args) == 'table')

    if #args ~= fun.nargs then
      local msg = #args < fun.nargs and "few" or "many"
      print(string.format("Too %s arguments for function '%s': expected %d, got %d", msg, lhs.val, fun.nargs, #args))
      return
    end

    lhs = fun.fun(table.unpack(args))
    flags.inside_func = false
  else
    assert(false, 'Token kind not handled: ' .. lhs.kind)
    return
  end

  while true do
    local next = tokens_peek(tokens)
    if not next then
      break
    elseif next.kind ~= 'operator' and next.kind ~= '(' and next.kind ~= ')' then
      print('Expected an operator or parenthesis, got: ' .. dump(next.val))
      return
    end

    local op = next.val
    if op == ',' and not flags.inside_func then
      print('Unexpected comma outside of function arguments')
      return
    end

    local prec = postfix_ops[op]
    if prec then
      if prec < min_prec then
        break
      end

      tokens_next(tokens)
      lhs = eval_unary(op, lhs)
      if not lhs then
        return
      end

      goto continue
    end

    ---@diagnostic disable-next-line: cast-local-type
    prec = operators[op]
    if prec then
      if prec[1] < min_prec then
        break
      end

      tokens_next(tokens)

      local rhs = evaluate_prec(tokens, prec[2], flags)
      if not rhs then
        return
      end

      lhs = eval_binary(op, lhs, rhs)
      if not lhs then
        return
      end

      goto continue
    end

    break
    ::continue::
  end

  return lhs
end

local function evaluate(tokens)
  local result = evaluate_prec(tokens, 0)
  return result
end

local function calc(args)
  args = vim.split(args, ' ')
  local tokens = tokenize(args)
  if not tokens then
    return
  end

  local result = evaluate(tokens)
  return result
end

local INT_MAX = 9223372036854775807
local INT_MIN = -9223372036854775808

vim.api.nvim_create_user_command('Calc', function(args)
  local result = calc(args.args)
  if result then
    if math.floor(result) == result and result < INT_MAX and result >= INT_MIN then
      print(string.format("%d\t(0x%X 0b%s)", result, result, dec2bin(result)))
    else
      print(string.format("%s", tostring(result)))
    end
  end
end, { nargs = '+' })

vim.api.nvim_create_user_command('TestCalc', function(_)
  assert(calc '1' == 1)
  assert(calc '1+1' == 2)
  assert(calc '1/2' == 0.5)
  assert(calc '5-3' == 2)
  assert(calc '2*5+1' == 11)
  assert(calc '1+1*5' == 6)
  assert(calc '-1+1' == 0)
  assert(calc '1+-1' == 0)
  assert(calc '4!' == 24)
  assert(calc '(1+1)' == 2)
  assert(calc '(1+1)*5' == 10)
  assert(calc 'sin(0)' == 0)
  assert(calc 'sin(3.141592654/2)' == 1)
  assert(calc 'logn(8,2)' == 3)
  assert(calc 'log2(8)' == 3)
  print("Passed")
end, {})
