-- Coal power in Py, measured in the engine (tools/run-probe.ps1 coal-power-probe -Ticks 4400). On a
-- cleared piece of a new map it places, each on its own electric network:
--   A. a Coal powerplant MK 01 on Raw coal, its Molten salt topped up and its Hot molten salt taken
--      away every tick;
--   B. a Heat exchanger MK 01 on High-pressure steam (he-01), its Hot molten salt and Pressurized
--      water topped up, its Molten salt and steam taken away every tick;
--   C. a High-pressure steam turbine MK 01 fed 1000-degree steam, with a load that takes all it gives.
-- It prints what each stage took and gave per second over 60 s. Results are CF-COAL log lines.

local function out(fmt, ...) log("CF-COAL " .. string.format(fmt, ...)) end

local WINDOW = { 600, 4200 }

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

local function build()
  local surface = game.surfaces.nauvis
  surface.request_to_generate_chunks({ 40, 0 }, 4)
  surface.force_generate_chunk_requests()
  for _, e in pairs(surface.find_entities({ { -30, -30 }, { 110, 30 } })) do
    if e.type ~= "character" then e.destroy() end
  end
  local tiles = {}
  for x = -30, 109 do for y = -30, 29 do tiles[#tiles + 1] = { name = "landfill", position = { x, y } } end end
  surface.set_tiles(tiles)
  local force = game.forces.player
  force.recipes["coal-molten-salt-01"].enabled = true
  force.recipes["he-01"].enabled = true

  local s = {}
  s.plant = surface.create_entity({ name = "py-coal-powerplant-mk01", position = { 0.5, 0.5 }, force = "player" })
  s.plant.set_recipe("coal-molten-salt-01")
  s.fuel = s.plant.get_fuel_inventory()
  s.fuel.insert({ name = "raw-coal", count = 50 })
  s.ex = surface.create_entity({ name = "py-heat-exchanger", position = { 40.5, 0.5 }, force = "player" })
  s.ex.set_recipe("he-01")
  s.ex_pole = power(surface, { 45.5, 0.5 }, { 47, 1 }, 5e6, true)
  s.turbine = surface.create_entity({ name = "steam-turbine-mk01", position = { 80.5, 0.5 }, force = "player" })
  local right = math.ceil(s.turbine.bounding_box.right_bottom.x)
  s.turbine_pole = power(surface, { right + 0.5, 0.5 }, { right + 3, 1 }, 1e9, false)
  out("turbine fluid storages %d, capacity %s; exchanger %d, plant %d", s.turbine.fluids_count,
    tostring(s.turbine.get_fluid_capacity(1)), s.ex.fluids_count, s.plant.fluids_count)
  storage.s = s
  storage.count = {}
end

local function add(key, v) storage.count[key] = (storage.count[key] or 0) + v end

local function energy(pole)
  local st = pole.electric_network_statistics
  local made, used = 0, 0
  for _, v in pairs(st.output_counts) do made = made + v end
  for _, v in pairs(st.input_counts) do used = used + v end
  return made, used
end

local function snapshot()
  local s = storage.s
  return { ex = { energy(s.ex_pole) }, turbine = { energy(s.turbine_pole) } }
end

local function tick_fluids(measuring)
  local s = storage.s
  -- Top up by what is missing, take away whatever came out.
  local salt_in = s.plant.insert_fluid({ name = "molten-salt", amount = 1000, temperature = 1000 })
  local hot = s.plant.get_fluid_count("hot-molten-salt")
  if hot > 0 then s.plant.extract_fluid({ name = "hot-molten-salt", amount = hot }) end
  local coal = 0
  if s.fuel.get_item_count("raw-coal") < 20 then coal = s.fuel.insert({ name = "raw-coal", count = 20 }) end

  local hot_in = s.ex.insert_fluid({ name = "hot-molten-salt", amount = 1000, temperature = 1000 })
  local water_in = s.ex.insert_fluid({ name = "pressured-water", amount = 1000 })
  local steam = s.ex.get_fluid_count("pressured-steam")
  if steam > 0 then s.ex.extract_fluid({ name = "pressured-steam", amount = steam }) end
  local salt = s.ex.get_fluid_count("molten-salt")
  if salt > 0 then s.ex.extract_fluid({ name = "molten-salt", amount = salt }) end

  local fed = s.turbine.insert_fluid({ name = "pressured-steam", amount = 1000, temperature = 1000 })
  if not measuring then return end
  add("A molten salt taken", salt_in)
  add("A hot molten salt made", hot)
  add("A raw coal put in", coal)
  add("B hot molten salt taken", hot_in)
  add("B pressurized water taken", water_in)
  add("B steam made", steam)
  add("B molten salt back", salt)
  add("C steam taken", fed)
end

script.on_init(build)

script.on_event(defines.events.on_tick, function(event)
  local t = event.tick
  if t == WINDOW[1] then
    storage.count = {}
    storage.start = snapshot()
    storage.coal0 = storage.s.fuel.get_item_count("raw-coal")
    out("window %d-%d s", WINDOW[1] / 60, WINDOW[2] / 60)
  end
  if storage.s then tick_fluids(t > WINDOW[1] and t <= WINDOW[2]) end
  if t == WINDOW[2] then
    local secs = (WINDOW[2] - WINDOW[1]) / 60
    local a, b = storage.start, snapshot()
    local names = {}
    for k in pairs(storage.count) do names[#names + 1] = k end
    table.sort(names)
    for _, k in ipairs(names) do out("  %s: %.3f/s", k, storage.count[k] / secs) end
    local s = storage.s
    out("  A raw coal burnt: %.3f/s", (storage.coal0 + storage.count["A raw coal put in"] - s.fuel.get_item_count("raw-coal")) / secs)
    out("  B network used %.3f MW", (b.ex[2] - a.ex[2]) / secs / 1e6)
    out("  C turbine gave %.3f MW", (b.turbine[1] - a.turbine[1]) / secs / 1e6)
    local status = {}
    for k, v in pairs(defines.entity_status) do status[v] = k end
    out("  status: plant %s, exchanger %s, turbine %s", status[s.plant.status] or "-", status[s.ex.status] or "-", status[s.turbine.status] or "-")
  end
end)
