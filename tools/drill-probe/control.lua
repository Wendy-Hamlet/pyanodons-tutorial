-- Does a Burner mining drill that cannot put its ore anywhere still burn fuel? Two drills on Iron
-- ore, each with 5 Raw coal: one drops into an empty chest, the other into a full one. After one
-- minute the fuel left in both is compared. Results are CF-DRILL log lines.

local function out(fmt, ...) log("CF-DRILL " .. string.format(fmt, ...)) end

local function setup(surface, x, full)
  local tiles = {}
  for dx = 0, 1 do for dy = 0, 1 do
    surface.create_entity({ name = "iron-ore", position = { x + dx + 0.5, dy + 0.5 }, amount = 100000 })
  end end
  local drill = surface.create_entity({ name = "burner-mining-drill", position = { x + 1, 1 },
    direction = defines.direction.north, force = "player" })
  drill.get_fuel_inventory().insert({ name = "raw-coal", count = 5 })
  local p = drill.drop_position
  local chest = surface.create_entity({ name = "wooden-chest", position = p, force = "player" })
  if full then chest.insert({ name = "iron-ore", count = 100000 }) end
  return { drill = drill, chest = chest, full = full }
end

local function fuel_left(d)
  local burner = d.drill.burner
  local count = d.drill.get_fuel_inventory().get_item_count("raw-coal")
  return count * 3 + burner.remaining_burning_fuel / 1e6 -- MJ, Raw coal holds 3 MJ
end

script.on_init(function()
  local surface = game.surfaces.nauvis
  surface.request_to_generate_chunks({ 0, 0 }, 2)
  surface.force_generate_chunk_requests()
  for _, e in pairs(surface.find_entities({ { -20, -20 }, { 20, 20 } })) do e.destroy() end
  storage.d = { setup(surface, 0, false), setup(surface, 8, true) }
end)

script.on_event(defines.events.on_tick, function(event)
  if event.tick == 60 then
    for _, d in ipairs(storage.d) do d.start = fuel_left(d) end
  elseif event.tick == 3660 then
    for _, d in ipairs(storage.d) do
      out("%s chest: status %s, fuel used in 60 s %.2f MJ, ore in chest %d", d.full and "full" or "empty",
        tostring(table.concat({ (function() for k, v in pairs(defines.entity_status) do if v == d.drill.status then return k end end end)() })),
        d.start - fuel_left(d), d.chest.get_item_count("iron-ore"))
    end
    out("DONE")
  end
end)
