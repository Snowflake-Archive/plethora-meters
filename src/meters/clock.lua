-- Displays the current time

local function n(num)
  if num >= 10 then return tostring(num) else return "0" .. tostring(num) end
end

return function(canvas, config)
  local clock = canvas.addText( { x = config.x, y = config.y }, "00:00:00", nil, config.textSize )
  local module = {}

  -- "tick" runs once a second
  module.tick = function()
    local t = os.date("*t", (os.epoch("utc") + tonumber(config.tzoffset or 0) * 60 * 60 * 1000) / 1000)
    clock.setText(("%s:%s:%s"):format(n(t.hour), n(t.min), n(t.sec)))
  end

  module.w = 50
  module.h = 8 * config.textSize

  return module
end