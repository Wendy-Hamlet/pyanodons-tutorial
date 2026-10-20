-- What-if for Dig sites in a copy of a save (tools/save-probe.ps1): puts COUNT creatures of NAME
-- in every Dig site's slots and keeps each site's food slots full of Guts, then counts the trips
-- (Guts eaten) and the ore brought back after a warm-up. Variant: "name,count,warm_s,measure_s".

local variant = require("variant")
local NAME, COUNT, WARM, MEASURE = variant:match("^([%w%-_]+),(%d+),(%d+),(%d+)$")
COUNT, WARM, MEASURE = tonumber(COUNT), tonumber(WARM) * 60, tonumber(MEASURE) * 60

local function out(fmt, ...) log("CF-DIG " .. string.format(fmt, ...)) end
local start, stats, t0, s0, o0

local function feed()
  for _, food in pairs(game.surfaces.nauvis.find_entities_filtered {name = "dino-dig-site-food-input"}) do
    local inv = food.get_inventory(defines.inventory.chest)
    inv.clear()
    inv.insert {name = "guts", count = 200}
  end
end

script.on_event(defines.events.on_tick, function(event)
  if not start then
    start = event.tick
    for _, site in pairs(game.surfaces.nauvis.find_entities_filtered {name = "dino-dig-site"}) do
      local inv = site.get_module_inventory()
      inv.clear()
      inv.insert {name = NAME, count = COUNT}
      out("site at %.1f,%.1f: %s", site.position.x, site.position.y, serpent.line(inv.get_contents()))
    end
    stats = game.forces.player.get_item_production_statistics("nauvis")
  end
  if event.tick % 60 == 0 then feed() end
  local age = event.tick - start
  if age == WARM then
    t0, s0, o0 = event.tick, stats.get_output_count("guts"), stats.get_input_count("nexelit-ore")
  elseif age == WARM + MEASURE then
    local trips = stats.get_output_count("guts") - s0
    local ore = stats.get_input_count("nexelit-ore") - o0
    local secs = (event.tick - t0) / 60
    out("%d x %s, %.0f s: %d trips (%.4f/s, %.4f/s each, %.2f s a trip), %d ore", COUNT, NAME, secs,
      trips, trips / secs, trips / secs / COUNT, COUNT * secs / math.max(trips, 1), ore)
  end
end)
