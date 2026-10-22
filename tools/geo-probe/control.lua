-- Geothermal power, measured in the engine (tools/run-probe.ps1 geo-probe -Ticks 8500). On a
-- cleared piece of a new map it places, each on its own electric network fed or loaded by an
-- Electric energy interface:
--   A. a Geothermal plant on a Geothermal fissure made by script, its Pressurized water topped up
--      and its Geothermal water taken away every tick;
--   B. a Regenerative heat exchanger on Steam (geo-he-00), its Geothermal water (3000 degrees)
--      topped up and its Steam taken away every tick;
--   C. two Steam engines, one fed 500-degree Steam (what B makes), one 250-degree Steam (what a
--      Boiler makes), each with a load that takes all it gives.
-- It prints what each stage took and gave per second over 60 s, first with no mining
-- productivity, then with +20 % (Mining productivity 1 and 2, as in the author's game).
-- With the variant "cracks" (tools/save-probe.ps1) it only lists the Geothermal fissures of a
-- save instead: position and amount. Results are CF-GEO log lines.

local function out(fmt, ...) log("CF-GEO " .. string.format(fmt, ...)) end

local ok, variant = pcall(require, "variant")
if not ok then variant = "" end

local WINDOWS = { { 600, 4200, 0 }, { 4800, 8400, 0.2 } }

-- The index of a fluid box by its production type ("input", "output", "input-output").
-- (Factorio 2.1 has no LuaFluidBox: fluids go through the entity's own *_fluid methods.) A mining
-- drill's input box is "input-output", so "input" also takes that.
local function box(entity, kind)
  for _, k in ipairs(kind == "input" and { "input", "input-output" } or { kind }) do
    for i = 1, entity.fluids_count do
      local p = entity.get_fluid_box_prototype(i)
      if p and p.object_name ~= "LuaFluidBoxPrototype" then p = p[1] end
      if p and p.production_type == k then return i, entity.get_fluid_capacity(i) end
    end
  end
end

local function power(surface, pole_at, source_at, watts, produce)
  local pole = surface.create_entity({ name = "small-electric-pole", position = pole_at, force = "player" })
  local eei = surface.create_entity({ name = "electric-energy-interface", position = source_at, force = "player" })
  eei.electric_buffer_size = watts
  if produce then
    eei.power_production = watts / 60
    eei.power_usage = 0
  else
    eei.power_production = 0
    eei.power_usage = watts / 60
  end
  return pole
end

local function list_cracks()
  for _, s in pairs(game.surfaces) do
    for _, c in pairs(s.find_entities_filtered({ name = "geothermal-crack" })) do
      out("fissure on %s at (%.1f, %.1f): amount %d", s.name, c.position.x, c.position.y, c.amount)
    end
  end
  out("done")
end

local function build()
  local surface = game.surfaces.nauvis
  surface.request_to_generate_chunks({ 40, 0 }, 4)
  surface.force_generate_chunk_requests()
  local area = { { -20, -20 }, { 100, 20 } }
  for _, e in pairs(surface.find_entities(area)) do
    if e.type ~= "character" then e.destroy() end
  end
  local tiles = {}
  for x = -20, 99 do for y = -20, 19 do tiles[#tiles + 1] = { name = "landfill", position = { x, y } } end end
  surface.set_tiles(tiles)
  local force = game.forces.player
  force.recipes["geo-he-00"].enabled = true

  local s = {}
  -- A. the plant
  s.crack = surface.create_entity({ name = "geothermal-crack", position = { 0, 0 }, amount = 10000000 })
  -- A 10 x 10 plant stands on whole tiles, the 11 x 11 fissure on a tile centre.
  s.plant = surface.create_entity({ name = "geothermal-plant-mk01", position = { 0, 0 }, force = "player" })
  s.plant_pole = power(surface, { 5.5, 0.5 }, { 7, 1 }, 5e6, true)
  out("fissure at (%.1f, %.1f), plant at (%.1f, %.1f), fluid storages %d", s.crack.position.x, s.crack.position.y,
    s.plant.position.x, s.plant.position.y, s.plant.fluids_count)
  for i = 1, s.plant.fluids_count do
    local p = s.plant.get_fluid_box_prototype(i)
    if p and p.object_name ~= "LuaFluidBoxPrototype" then p = p[1] end
    out("plant storage %d: %s, capacity %s", i, p and p.production_type or "no prototype", tostring(s.plant.get_fluid_capacity(i)))
  end
  s.plant_out = box(s.plant, "output")
  s.plant_in, s.plant_in_cap = box(s.plant, "input")
  if not s.plant_in then s.plant_in = s.plant_out == 1 and 2 or 1; s.plant_in_cap = s.plant.get_fluid_capacity(s.plant_in) end
  -- B. the exchanger
  s.rhe = surface.create_entity({ name = "rhe", position = { 30.5, 0.5 }, force = "player" })
  s.rhe.set_recipe("geo-he-00")
  s.rhe_pole = power(surface, { 33.5, 0.5 }, { 35, 1 }, 5e6, true)
  s.rhe_in, s.rhe_in_cap = box(s.rhe, "input")
  s.rhe_out = box(s.rhe, "output")
  -- C. two engines with a load each
  s.engines = {}
  for i, temp in ipairs({ 500, 250 }) do
    local x = 40 + 20 * i
    local engine = surface.create_entity({ name = "steam-engine", position = { x + 0.5, 0.5 }, force = "player" })
    local pole = power(surface, { x + 2.5, 0.5 }, { x + 4, 1 }, 50e6, false)
    local index, cap = box(engine, "input-output")
    if not index then index, cap = 1, engine.get_fluid_capacity(1) end
    s.engines[i] = { entity = engine, pole = pole, temp = temp, index = index, cap = cap }
  end
  out("boxes: plant in %s (%s) out %s, exchanger in %s (%s) out %s, engine %s (%s)", tostring(s.plant_in),
    tostring(s.plant_in_cap), tostring(s.plant_out), tostring(s.rhe_in), tostring(s.rhe_in_cap), tostring(s.rhe_out),
    tostring(s.engines[1].index), tostring(s.engines[1].cap))
  storage.s = s
  storage.count = {}
end

local function add(key, v) storage.count[key] = (storage.count[key] or 0) + v end

local function tick_fluids(measuring)
  local s = storage.s
  local function take(entity, index)
    return entity.clear_fluid(index)
  end
  local function top(entity, index, cap, name, temp)
    local f = entity.get_fluid(index)
    local used = cap - (f and f.amount or 0)
    entity.set_fluid(index, { name = name, amount = cap, temperature = temp })
    return used
  end
  local used = top(s.plant, s.plant_in, s.plant_in_cap, "pressured-water", 10)
  local made = take(s.plant, s.plant_out)
  local used2 = top(s.rhe, s.rhe_in, s.rhe_in_cap, "geothermal-water", 3000)
  local made2 = take(s.rhe, s.rhe_out)
  local engine_use = {}
  for i, e in ipairs(s.engines) do engine_use[i] = top(e.entity, e.index, e.cap, "steam", e.temp) end
  if not measuring then return end
  add("pressured water used", used)
  if made then add("geothermal water made", made.amount) storage.water_temp = made.temperature end
  add("geothermal water used", used2)
  if made2 then add("steam made", made2.amount) storage.steam_temp = made2.temperature end
  for i, e in ipairs(s.engines) do add(("steam used by the %d-degree engine"):format(e.temp), engine_use[i]) end
end

local function energy(pole)
  local st = pole.electric_network_statistics
  local made, used = 0, 0
  for _, v in pairs(st.output_counts) do made = made + v end
  for _, v in pairs(st.input_counts) do used = used + v end
  return made, used
end

local function snapshot()
  local s = storage.s
  local snap = { amount = s.crack.amount, plant = { energy(s.plant_pole) }, rhe = { energy(s.rhe_pole) }, engines = {} }
  for i, e in ipairs(s.engines) do snap.engines[i] = { energy(e.pole) } end
  return snap
end

script.on_init(function()
  if variant == "cracks" then return end
  build()
end)

script.on_event(defines.events.on_tick, function(event)
  if variant == "cracks" then
    script.on_event(defines.events.on_tick, nil)
    list_cracks()
    return
  end
  local t = event.tick
  local measuring = false
  for _, w in ipairs(WINDOWS) do
    if t == w[1] then
      game.forces.player.mining_drill_productivity_bonus = w[3]
      storage.count = {}
      storage.start = snapshot()
      out("window %d-%d s, mining productivity +%d %%", w[1] / 60, w[2] / 60, w[3] * 100)
    end
    if t > w[1] and t <= w[2] then measuring = true end
  end
  if storage.s then tick_fluids(measuring) end
  for _, w in ipairs(WINDOWS) do
    if t == w[2] then
      local secs = (w[2] - w[1]) / 60
      local a, b = storage.start, snapshot()
      local names = {}
      for k in pairs(storage.count) do names[#names + 1] = k end
      table.sort(names)
      for _, k in ipairs(names) do out("  %s: %.2f/s", k, storage.count[k] / secs) end
      out("  geothermal water %s degrees, steam %s degrees", tostring(storage.water_temp), tostring(storage.steam_temp))
      out("  fissure amount used: %.2f/s (%d left)", (a.amount - b.amount) / secs, b.amount)
      out("  plant network: used %.3f MW", (b.plant[2] - a.plant[2]) / secs / 1e6)
      out("  exchanger network: used %.3f MW", (b.rhe[2] - a.rhe[2]) / secs / 1e6)
      for i, e in ipairs(storage.s.engines) do
        out("  %d-degree engine: gave %.3f MW", e.temp, (b.engines[i][1] - a.engines[i][1]) / secs / 1e6)
      end
      local status = {}
      for k, v in pairs(defines.entity_status) do status[v] = k end
      out("  plant status %s (mining target %s), exchanger status %s", status[storage.s.plant.status] or "-",
        storage.s.plant.mining_target and storage.s.plant.mining_target.name or "none", status[storage.s.rhe.status] or "-")
    end
  end
end)
