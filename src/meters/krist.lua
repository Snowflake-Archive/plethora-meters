-- Displays the balance of a krist address

local function truncateValue(value)
  if value > 1000000 then
    return tostring(math.floor(value / 100000) * 0.1) .. "M"
  elseif value > 1000 then
    return tostring(math.floor(value / 100) * 0.1) .. "K"

  end

  return tostring(value)
end

local function commaizeValue(value)
  local str = tostring(value)
  local output = ""
  local min = #str
  for i = #str - 3, 1, -3 do
    output = output .. "," .. str:sub(i, i + 2)
    min = i
  end
  return str:sub(1, min) .. output
end

return function(canvas, config)
  local krist = canvas.addText( { x = config.x, y = config.y }, "Balance of " .. config.kristName .. ": unknown", nil, config.textSize )
  local module = {}

  local url = "https://krist.dev/addresses/" .. config.kristName
  local balance = 0
  local didError = false

  local function updateBalance()
    local ok, err = pcall(function()
      local f = http.get(url)
      local data = textutils.unserialiseJSON(f.readAll())
      f.close()

      balance = data.address.balance
      krist.setColor(0xFFFFFFFF)
      krist.setText("Balance of " .. config.kristName .. ": K" .. (config.disableTruncate and commaizeValue(balance) or truncateValue(balance)))
    end)

    if not ok then
      didError = true
      krist.setColor(0xCC4C4CFF)
      krist.setText("Could not get balance of address " .. config.kristName .. ": " .. err)
    end
  end

  updateBalance()

  -- "tick" runs once a second
  module.tick = function(tick)
    if didError and tick % 5 == 0 then
      updateBalance()
    elseif tick % 60 == 0 then
      updateBalance()
    end
  end

  module.w = 125
  module.h = 8 * config.textSize

  return module
end