-- Change this to the base path of your main file
local PATH = "/newoverlay"

local config = {}

local colors = {
  0xff000077,
  0xffff0077,
  0x00ff0077,
  0x00ffff77,
  0x0000ff77,
  0xff00ff77,
  0xffffff77
}

local f = fs.open(PATH .. "/config.lua", "r")
local config = textutils.unserialise(f.readAll())
f.close()

local ni = peripheral.wrap("back")
local canvas = ni.canvas()
canvas.clear()

local meters = {}

print("Loading meters")
for i, v in pairs(config.meters) do
  local data = v
  data.id = data.id or data.name
  print("Loading meter", data.name, "(" .. data.id .. ")")

  local ok, err = pcall(function()
    if type(v.y) == "string" then
      local after = v.y:match("after:([%a%d_%-]+)")
      local operation, value = v.y:match("([%+%-])(%d+)$")

      local yValue = v.y

      if after then
        local found = false

        for i, v in pairs(meters) do
          if v.id == after then
            yValue = v.y + v.meter.h
            found = true
          end
        end

        if found == false then
          error("could not find meter id " .. after .. ". ensure it is loaded prior to loading this meter")
          return
        end
      end

      if operation and value then
        if operation == "+" then
          yValue = yValue + value
        elseif operation == "-" then
          yValue = yValue - value
        end
      end

      v.y = yValue
    end

    local meterRequire = require("meters." .. v.name)
    local meter = meterRequire(canvas, v)

    if config.debug.drawBoundingBoxes then
      local color = colors[(i % #colors) == 0 and #colors or (i % #colors)]

      canvas.addText( { x = v.x, y = v.y - 3 }, ("%s (%s) (%d, %d)"):format(v.name, v.id, v.x, v.y), color, 0.3 )
      canvas.addRectangle(v.x, v.y, meter.w, meter.h, color, 4)
    end

    data.meter = meter
  end)

  if not ok then
    canvas.addText( { x = v.x, y = (type(v.y) == "number" and v.y or 0) }, "failed to load meter " .. v.name .. " (id: " .. v.id .. ")", 0xCC4C4CFF, 0.4 )
    canvas.addText( { x = v.x, y = (type(v.y) == "number" and v.y or 0) + 4 }, err, 0xCC4C4CFF, 0.4 )
    printError("failed to load meter " .. v.name .. " (id: " .. v.id .. ")")
    printError(err)
  else
    meters[#meters + 1] = data
  end
end

parallel.waitForAll(function()

end, function()
  local tick = 1

  while true do
    local start = os.epoch("utc")

    for i, v in pairs(meters) do
      local ok, err = pcall(function()
        v.meter.tick(tick)
      end)
      if not ok then printError("could not tick meter " .. v.name .. ": " .. err) end
    end

    tick = tick + 1

    local time = (os.epoch("utc") - start) / 1000
    sleep(math.max(1 - time, 0))
  end
end)
