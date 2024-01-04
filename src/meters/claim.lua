-- Displays the owner and name of the current claim you are in via GPS and Dynmap

local function truncate(str, max)
  if #str > max then
    local withoutParenthesis = str:gsub("%(.-%)", "")

    if #withoutParenthesis > max then
      return (withoutParenthesis:sub(1, max - 3):gsub("%s+$", "")) .. "..."
    else
      return withoutParenthesis:gsub("%s+$", "")
    end
  end
  return str
end

return function(canvas, config)
  local claim = canvas.addText( { x = config.x, y = config.y }, "Unknown", nil, config.textSize )
  local module = {}
  local claims = {}

  local function updateClaimData()
    print("[claim] Updating claim data")

    local start = os.epoch("utc")
    local req = http.get("https://dynmap.sc3.io/tiles/_markers_/marker_SwitchCraft.json")
    local data = textutils.unserialiseJSON(req.readAll()).sets

    for i, v in pairs(data["claimkit.adminclaims"].areas) do
      local name = v.label
      table.insert(claims, {
        minX = math.min(v.x[1], v.x[2], v.x[3], v.x[4]),
        maxX = math.max(v.x[1], v.x[2], v.x[3], v.x[4]),
        minZ = math.min(v.z[1], v.z[2], v.z[3], v.z[4]),
        maxZ = math.max(v.z[1], v.z[2], v.z[3], v.z[4]),
        owner = "SwitchCraft",
        name = name,
      })
    end

    for i, v in pairs(data["claimkit.claims"].areas) do
      local name = v.label
      local owner = v.desc:match("Owner:</b> (.-)</div>")
      if owner == nil then print("No owner!", v.desc) end
      table.insert(claims, {
        minX = math.min(v.x[1], v.x[2], v.x[3], v.x[4]),
        maxX = math.max(v.x[1], v.x[2], v.x[3], v.x[4]),
        minZ = math.min(v.z[1], v.z[2], v.z[3], v.z[4]),
        maxZ = math.max(v.z[1], v.z[2], v.z[3], v.z[4]),
        owner = owner,
        name = name
      })
    end
    print("[claim] Updating claim data took " .. os.epoch("utc") - start .. "ms")
  end

  updateClaimData()

  -- "tick" runs once a second
  module.tick = function(tick)
    -- update claim data once every ten minutes
    if tick % (60 * 10) == 0 then updateClaimData() end

    local x, y, z = gps.locate()
    local didFindClaim

    for i, v in pairs(claims) do
      if x >= v.minX and x <= v.maxX and z >= v.minZ and z <= v.maxZ then
        didFindClaim = v
        break
      end
    end

    claim.setText(didFindClaim and "Owner: " .. (didFindClaim.owner or "unknown") .. (didFindClaim.name and " (" .. truncate(didFindClaim.name, 30) .. ")") or "Wilderness")
  end

  module.w = 150
  module.h = 8 * config.textSize

  return module
end