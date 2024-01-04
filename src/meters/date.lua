-- Displays the current date

local weekdays = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"}
local months = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"}

return function(canvas, config)
  local date = canvas.addText( { x = config.x, y = config.y }, "Mon, Jan 1 2000", nil, config.textSize )
  local module = {}

  -- "tick" runs once a second
  module.tick = function()
    local t = os.date("*t", (os.epoch("utc") + tonumber(config.tzoffset or 0) * 60 * 60 * 1000) / 1000)
    date.setText(("%s, %s %d %d"):format(weekdays[t.wday], months[t.month], t.day, t.year))
  end

  module.w = 50
  module.h = 8 * config.textSize

  return module
end