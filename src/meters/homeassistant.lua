-- Displays the current time

return function(canvas, config)
  local text = canvas.addText( { x = config.x, y = config.y }, "HomeAssistant Initalizing", nil, config.textSize )
  local module = {}

  local function updateValue()
    print("[hass] Updating value of " .. config.hass.entity)
    local h = http.get(config.hass.url .. "/api/states/" .. config.hass.entity, {
      ["Content-Type"] = "application/json; charset=utf-8",
      ["Authorization"] = "Bearer " .. config.hass.authorization
    })
    local data = textutils.unserialiseJSON(h.readAll())
    h.close()

    -- when sending temperature readings or other special characters, a \194 character gets added in there for some reason
    -- this fixes that
    text.setText(data.attributes.friendly_name .. ": " .. data.state .. tostring(data.attributes.unit_of_measurement:gsub("\194", "")))
  end

  updateValue()

  -- "tick" runs once a second
  module.tick = function(tick)
    if tick % 10 == 0 then
      updateValue()
    end
  end

  module.w = 50
  module.h = 8 * config.textSize

  return module
end