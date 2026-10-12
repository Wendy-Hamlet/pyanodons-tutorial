-- Measures a save as it stands, over a longer window than the inspector's one minute
-- (tools/save-probe.ps1 runs it in a copy of the save; nothing in the base is changed).
-- After a warm-up it takes the force's production statistics, then samples the status of every
-- crafting machine and drill once a second, grouped by name and recipe (drills: by mined
-- resource), and at the end prints what the whole base made and used per second.
-- Variant: "WARM,MEASURE" in seconds (default "60,600").

local variant = require("variant")
local WARM, MEASURE = variant:match("^(%d+),(%d+)$")
WARM, MEASURE = tonumber(WARM) or 60, tonumber(MEASURE) or 600

local function out(fmt, ...) log("CF-RATE " .. string.format(fmt, ...)) end
local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end

local function flow(stats)
  return { produced = stats.input_counts, consumed = stats.output_counts }
end

local function snapshot(surface)
  local force = game.forces.player
  return {
    items = flow(force.get_item_production_statistics(surface)),
    fluids = flow(force.get_fluid_production_statistics(surface)),
  }
end

local function group_key(e)
  if e.type == "mining-drill" then
    local t = e.mining_target
    return e.name .. " on " .. (t and t.name or "-")
  end
  local r = e.get_recipe()
  local name = r and r.name
  if not name and e.type == "furnace" and e.previous_recipe then
    name = e.previous_recipe.name
    if type(name) ~= "string" then name = name.name end
  end
  return e.name .. " / " .. (name or "-")
end

script.on_init(function()
  storage.start = game.tick
  out("loaded at tick %d; warm %d s, measure %d s", game.tick, WARM, MEASURE)
end)

script.on_nth_tick(60, function()
  local surface = game.surfaces.nauvis
  local t = game.tick - storage.start
  if t < WARM * 60 then return end
  if not storage.before then
    storage.before = snapshot(surface)
    storage.samples = {}
    storage.machines = surface.find_entities_filtered({ force = "player",
      type = { "assembling-machine", "furnace", "mining-drill" } })
    return
  end
  if storage.done then return end
  for _, e in pairs(storage.machines) do
    if e.valid then
      local k = group_key(e)
      local g = storage.samples[k] or {}
      storage.samples[k] = g
      local s = STATUS[e.status] or "?"
      g[s] = (g[s] or 0) + 1
    end
  end
  if t < (WARM + MEASURE) * 60 then return end
  storage.done = true
  local now = snapshot(surface)
  for _, kind in ipairs({ "items", "fluids" }) do
    for _, dir in ipairs({ "produced", "consumed" }) do
      local list = {}
      for name, count in pairs(now[kind][dir]) do
        local d = (count - (storage.before[kind][dir][name] or 0)) / MEASURE
        if d > 0.004 then list[#list + 1] = { name, d } end
      end
      table.sort(list, function(a, b) return a[2] > b[2] end)
      local parts = {}
      for _, p in ipairs(list) do parts[#parts + 1] = string.format("%s %.3f", p[1], p[2]) end
      out("%s %s per s: %s", kind, dir, table.concat(parts, ", "))
    end
  end
  local keys = {}
  for k in pairs(storage.samples) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local parts, total = {}, 0
    for _, n in pairs(storage.samples[k]) do total = total + n end
    for s, n in pairs(storage.samples[k]) do parts[#parts + 1] = string.format("%s %.0f%%", s, 100 * n / total) end
    table.sort(parts)
    out("status %s (%d samples): %s", k, total, table.concat(parts, ", "))
  end
end)
