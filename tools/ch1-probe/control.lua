-- Chapter 1 measurements (tutorial facts): trigger technologies, ash handling, burner rates, steam.
-- Run with --create, then --benchmark for ~3700 ticks; results are CF-CH1 log lines.

local T = 3600 -- measurement window in ticks for rates
local T_END = 9000 -- later checks: trigger technologies and the offshore pump

local function status(e)
  for k, v in pairs(defines.entity_status) do if v == e.status then return k end end
  return tostring(e.status)
end

local function out(fmt, ...) log("CF-CH1 " .. string.format(fmt, ...)) end

local function ore_under(surface, name, x, y, w, h)
  for tx = x, x + w - 1 do
    for ty = y, y + h - 1 do
      surface.create_entity({ name = name, position = { tx + 0.5, ty + 0.5 }, amount = 100000 })
    end
  end
end

-- Burner inserter at (x, y) taking from `source` into a new chest at its drop position.
local function puller(surface, source, x, y)
  local inserter = surface.create_entity({ name = "burner-inserter", position = { x, y }, direction = defines.direction.north, force = "player" })
  local sb = source.bounding_box
  local p = inserter.pickup_position
  if not (p.x > sb.left_top.x and p.x < sb.right_bottom.x and p.y > sb.left_top.y and p.y < sb.right_bottom.y) then
    inserter.direction = defines.direction.south
  end
  local d = inserter.drop_position
  local chest = surface.create_entity({ name = "iron-chest", position = { d.x, d.y }, force = "player" })
  return inserter, chest
end

script.on_init(function()
  local surface = game.surfaces.nauvis
  surface.request_to_generate_chunks({ 0, 0 }, 4)
  surface.force_generate_chunk_requests()
  local area = { { -120, -120 }, { 120, 120 } }
  for _, e in pairs(surface.find_entities(area)) do
    if e.valid and e.type ~= "character" then e.destroy() end
  end
  local tiles = {}
  for x = -120, 119 do
    for y = -120, 119 do tiles[#tiles + 1] = { name = "lab-dark-1", position = { x, y } } end
  end
  surface.set_tiles(tiles)
  local s = {}
  storage.s = s

  -- E1 trigger technologies: smelt in furnaces fuelled by logs (no ash).
  s.f_iron = surface.create_entity({ name = "stone-furnace", position = { -40, -40 }, force = "player" })
  s.f_iron.insert({ name = "iron-ore", count = 200 })
  s.f_iron.get_fuel_inventory().insert({ name = "log", count = 20 })
  -- Copper runs from tick 0, before steam-power (its prerequisite) is done: do those plates count?
  s.copper = {}
  for i = 0, 3 do
    local f = surface.create_entity({ name = "stone-furnace", position = { -36 + 4 * i, -40 }, force = "player" })
    f.insert({ name = "copper-ore", count = 200 })
    f.get_fuel_inventory().insert({ name = "log", count = 20 })
    s.copper[#s.copper + 1] = f
  end
  s.f_copper = s.copper[1]

  -- E2 ash: a furnace and a drill with a full burnt-result slot, with and without a puller.
  local function ash_furnace(x, pull)
    local f = surface.create_entity({ name = "stone-furnace", position = { x, 0 }, force = "player" })
    f.insert({ name = "iron-ore", count = 200 })
    f.get_fuel_inventory().insert({ name = "raw-coal", count = 5 })
    f.get_burnt_result_inventory().insert({ name = "ash", count = 1000 })
    local chest
    if pull then _, chest = puller(surface, f, x - 0.5, 1.5) end
    return f, chest
  end
  s.furnace_full = ash_furnace(-20, false)
  s.furnace_pull, s.furnace_pull_chest = ash_furnace(-14, true)

  local function ash_drill(x, pull)
    ore_under(surface, "iron-ore", x - 1, 19, 2, 2)
    local d = surface.create_entity({ name = "burner-mining-drill", position = { x, 20 }, direction = defines.direction.south, force = "player" })
    d.get_fuel_inventory().insert({ name = "raw-coal", count = 5 })
    d.get_burnt_result_inventory().insert({ name = "ash", count = 1000 })
    local dp = d.drop_position
    local out_chest = surface.create_entity({ name = "iron-chest", position = { dp.x, dp.y }, force = "player" })
    local chest
    if pull then _, chest = puller(surface, d, x - 0.5, 18.5) end
    return d, out_chest, chest
  end
  s.drill_full, s.drill_full_out = ash_drill(-20, false)
  s.drill_pull, s.drill_pull_out, s.drill_pull_chest = ash_drill(-14, true)

  -- E2b: does an inserter pulling from a burner drill take its fuel? Unfiltered vs filtered to ash.
  local function fuel_drill(x, filter)
    ore_under(surface, "iron-ore", x - 1, 29, 2, 2)
    local d = surface.create_entity({ name = "burner-mining-drill", position = { x, 30 }, direction = defines.direction.south, force = "player" })
    d.get_fuel_inventory().insert({ name = "raw-coal", count = 50 })
    local dp = d.drop_position
    surface.create_entity({ name = "iron-chest", position = { dp.x, dp.y }, force = "player" })
    local inserter, chest = puller(surface, d, x - 0.5, 28.5)
    if filter then
      inserter.use_filters = true
      inserter.set_filter(1, filter)
    end
    return d, chest
  end
  s.drill_unfiltered, s.drill_unfiltered_chest = fuel_drill(0, nil)
  s.drill_filtered, s.drill_filtered_chest = fuel_drill(6, "ash")

  -- E2c: a coal-fuelled furnace with two filtered output inserters: plates on one side, ash on the other.
  s.split_furnace = surface.create_entity({ name = "stone-furnace", position = { 0, 0 }, force = "player" })
  s.split_furnace.insert({ name = "iron-ore", count = 200 })
  s.split_furnace.get_fuel_inventory().insert({ name = "raw-coal", count = 20 })
  s.split_furnace.get_burnt_result_inventory().insert({ name = "ash", count = 990 })
  local plate_inserter, plate_chest = puller(surface, s.split_furnace, -0.5, 1.5)
  plate_inserter.use_filters = true
  plate_inserter.set_filter(1, "iron-plate")
  local ash_inserter, ash_chest = puller(surface, s.split_furnace, 0.5, -1.5)
  ash_inserter.use_filters = true
  ash_inserter.set_filter(1, "ash")
  s.split_plate_chest, s.split_ash_chest = plate_chest, ash_chest

  -- E3 rates: burner drills on iron ore and raw coal, fuelled with raw coal, output into chests.
  local function rate_drill(x, ore)
    ore_under(surface, ore, x - 1, 39, 2, 2)
    local d = surface.create_entity({ name = "burner-mining-drill", position = { x, 40 }, direction = defines.direction.south, force = "player" })
    d.get_fuel_inventory().insert({ name = "raw-coal", count = 50 })
    local dp = d.drop_position
    return d, surface.create_entity({ name = "iron-chest", position = { dp.x, dp.y }, force = "player" })
  end
  s.drill_iron, s.drill_iron_chest = rate_drill(-20, "iron-ore")
  s.drill_coal, s.drill_coal_chest = rate_drill(-14, "raw-coal")

  -- E4 steam: a boiler fed water by script, and a steam engine fed 250 C steam under a large load.
  s.boiler = surface.create_entity({ name = "boiler", position = { 20, 0 }, force = "player" })
  s.boiler.get_fuel_inventory().insert({ name = "raw-coal", count = 50 })
  s.boiler_pull_inserter, s.boiler_pull_chest = puller(surface, s.boiler, 20, 1.5)
  s.engine = surface.create_entity({ name = "steam-engine", position = { 40, 0 }, force = "player" })
  surface.create_entity({ name = "small-electric-pole", position = { 42.5, 0.5 }, force = "player" })
  s.load = surface.create_entity({ name = "electric-energy-interface", position = { 44, 2 }, force = "player" })
  s.load.power_production = 0
  s.load.power_usage = 20000000 / 60
  s.load.electric_buffer_size = 20000000
  s.steam_made, s.steam_fed, s.energy = 0, 0, 0

  -- Offshore pump on dry land (pump-anywhere-fork is in the author's mod list).
  s.pump = surface.create_entity({ name = "offshore-pump", position = { 20, 30 }, force = "player" })
  out("offshore pump on land: %s", s.pump and "placed" or "cannot place")
  if s.pump then
    local target = s.pump.get_fluid_box_pipe_connections(1)[1].target_position
    s.pump_pipe = surface.create_entity({ name = "pipe", position = target, force = "player" })
  end
end)

local function copper_made(s)
  local n = 0
  for _, f in ipairs(s.copper) do n = n + f.products_finished end
  return n
end

script.on_event(defines.events.on_research_finished, function(event)
  local s = storage.s
  out("research finished at tick %d: %s (copper plates made so far %d)", event.tick, event.research.name,
    s and copper_made(s) or -1)
end)

script.on_event(defines.events.on_tick, function(event)
  local s = storage.s
  if not s or s.done then return end
  -- Keep the boiler supplied with water and drain its steam; keep the engine supplied with steam.
  s.boiler.insert_fluid({ name = "water", amount = 1000 })
  s.steam_made = s.steam_made + s.boiler.extract_fluid({ name = "steam", amount = 1000 })
  s.steam_fed = s.steam_fed + s.engine.insert_fluid({ name = "steam", amount = 1000, temperature = 250 })
  s.energy = s.energy + (s.engine.energy_generated_last_tick or 0)

  if event.tick == T_END then
    s.done = true
    out("at %d s: copper plates made %d; automation-science-pack researched: %s", T_END / 60, copper_made(s),
      tostring(game.forces.player.technologies["automation-science-pack"].researched))
    if s.pump_pipe then
      local fluid = s.pump_pipe.get_fluid(1)
      out("pipe after offshore pump: %s", fluid and (fluid.name .. " " .. string.format("%.1f", fluid.amount)) or "empty")
    end
    out("DONE")
    return
  end
  if event.tick ~= T then return end
  local sec = T / 60
  out("window %d s", sec)
  out("furnace_full: status %s, plates %d", status(s.furnace_full), s.furnace_full.products_finished)
  out("furnace_pull: status %s, plates %d, chest ash %d, chest plates %d", status(s.furnace_pull),
    s.furnace_pull.products_finished, s.furnace_pull_chest.get_item_count("ash"), s.furnace_pull_chest.get_item_count("iron-plate"))
  out("drill_full: status %s, ore out %d", status(s.drill_full), s.drill_full_out.get_item_count("iron-ore"))
  local pulled = {}
  for _, c in pairs(s.drill_pull_chest.get_inventory(defines.inventory.chest).get_contents()) do
    pulled[#pulled + 1] = c.name .. " " .. c.count
  end
  out("drill_pull: status %s, ore out %d, puller chest: %s", status(s.drill_pull),
    s.drill_pull_out.get_item_count("iron-ore"), table.concat(pulled, ", "))
  for _, case in ipairs({ { "unfiltered", s.drill_unfiltered, s.drill_unfiltered_chest }, { "filtered to ash", s.drill_filtered, s.drill_filtered_chest } }) do
    out("drill pulled by %s inserter: status %s, fuel left %d of 50, chest ash %d, chest raw coal %d", case[1],
      status(case[2]), case[2].get_fuel_inventory().get_item_count("raw-coal"), case[3].get_item_count("ash"),
      case[3].get_item_count("raw-coal"))
  end
  out("split furnace: status %s, plate chest: plates %d ash %d; ash chest: ash %d plates %d", status(s.split_furnace),
    s.split_plate_chest.get_item_count("iron-plate"), s.split_plate_chest.get_item_count("ash"),
    s.split_ash_chest.get_item_count("ash"), s.split_ash_chest.get_item_count("iron-plate"))
  out("drill_iron: %.2f ore/s, raw coal left %d of 50", s.drill_iron_chest.get_item_count("iron-ore") / sec,
    s.drill_iron.get_fuel_inventory().get_item_count("raw-coal"))
  out("drill_coal: %.2f raw coal/s, fuel left %d of 50", s.drill_coal_chest.get_item_count("raw-coal") / sec,
    s.drill_coal.get_fuel_inventory().get_item_count("raw-coal"))
  out("furnaces (log fuel): iron plates %.3f/s, copper plates %.3f/s", s.f_iron.products_finished / sec, s.f_copper.products_finished / sec)
  out("boiler: steam %.2f/s, raw coal left %d of 50, ash pulled %d, status %s", s.steam_made / sec,
    s.boiler.get_fuel_inventory().get_item_count("raw-coal"), s.boiler_pull_chest.get_item_count("ash"), status(s.boiler))
  out("steam engine: %.0f kW, steam used %.2f/s", s.energy / T * 60 / 1000, s.steam_fed / sec)
end)
