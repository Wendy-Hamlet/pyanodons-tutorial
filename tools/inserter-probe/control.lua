-- How many items per second an inserter moves in the cases designs use, and what a machine's
-- output port does. Results are CF-INSERTER log lines.
--   1. Per inserter type (no capacity bonus researched): chest -> chest (what machine -> machine
--      also is), chest -> moving belt, moving full belt -> chest and standing full belt -> chest.
--   2. A Soil extractor's output port (vector_to_place_result): straight into a Foundry standing
--      on the port tile, and onto a belt (which lane).

local N, E, W = defines.direction.north, defines.direction.east, defines.direction.west
local WARM, T = 300, 3600 -- ticks before measuring, ticks measured
local INSERTERS = { "burner-inserter", "inserter", "long-handed-inserter", "fast-inserter" }

local function out(fmt, ...) log("CF-INSERTER " .. string.format(fmt, ...)) end

local function must(entity, what)
  if not entity then out("FIXTURE FAILED: %s", what) end
  return entity
end

local surface

local function place(spec, what)
  spec.force = "player"
  return must(surface.create_entity(spec), what)
end

local VEC = { [E] = { 1, 0 }, [W] = { -1, 0 } }

-- Belt from x1 to x2 on row y flowing east, fed full by a loader from an infinity chest; with
-- `moving`, a loader at the far end takes everything into a chest, so the belt keeps flowing.
local function belt_row(x1, x2, y, fed, moving)
  for x = x1, x2 do place({ name = "transport-belt", position = { x + 0.5, y + 0.5 }, direction = E }, "belt") end
  if fed then
    place({ name = "loader", position = { x1 - 1, y + 0.5 }, direction = E, type = "output" }, "source loader")
    local c = place({ name = "infinity-chest", position = { x1 - 2.5, y + 0.5 } }, "source chest")
    if c then c.set_infinity_container_filter(1, { name = "iron-plate", count = 50, mode = "exactly" }) end
  end
  if moving then
    place({ name = "loader", position = { x2 + 2, y + 0.5 }, direction = E, type = "input" }, "sink loader")
    return place({ name = "iron-chest", position = { x2 + 3.5, y + 0.5 } }, "sink chest")
  end
end

-- One inserter at (x, 0) moving items north, with the given source and sink around it.
local function case(x, inserter, from, to)
  local ins = place({ name = inserter, position = { x + 0.5, 0.5 }, direction = N }, inserter)
  if not ins then return end
  -- Power for electric inserters: an energy interface beside a pole.
  place({ name = "medium-electric-pole", position = { x + 3.5, 0.5 } }, "pole")
  local eei = place({ name = "electric-energy-interface", position = { x + 7, 1 } }, "power")
  if eei then eei.electric_buffer_size = 1e9; eei.power_production = 1e7 end
  local p, d = ins.pickup_position, ins.drop_position
  local py, dy = math.floor(p.y), math.floor(d.y)
  local c = { label = string.format("%s: %s -> %s", inserter, from, to), ins = ins }
  if from == "chest" then
    c.source = place({ name = "iron-chest", position = { x + 0.5, py + 0.5 } }, "source chest")
    c.source.insert({ name = "iron-plate", count = 2000 })
  else
    belt_row(x - 2, x + 2, py, true, from == "moving belt")
  end
  if to == "chest" then
    c.sink = place({ name = "iron-chest", position = { x + 0.5, dy + 0.5 } }, "sink chest")
  else
    c.sink = belt_row(x - 2, x + 2, dy, false, true)
  end
  return c
end

local function count(c)
  -- Items moved so far: what left the source chest, else what reached the sink chest.
  if c.source then return 2000 - c.source.get_item_count("iron-plate") end
  return c.sink.get_item_count("iron-plate")
end

local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end

script.on_init(function()
  surface = game.surfaces.nauvis
  surface.request_to_generate_chunks({ 0, 0 }, 4)
  surface.force_generate_chunk_requests()
  for _, e in pairs(surface.find_entities({ { -120, -120 }, { 120, 120 } })) do if e.valid then e.destroy() end end
  local tiles = {}
  for x = -120, 119 do for y = -120, 119 do tiles[#tiles + 1] = { name = "lab-dark-1", position = { x, y } } end end
  surface.set_tiles(tiles)

  -- The extractor and foundry recipes are locked at the start.
  for _, r in pairs({ "extract-limestone-01", "steel-plate" }) do game.forces.player.recipes[r].enabled = true end

  storage.cases = {}
  local x = -100
  for _, inserter in ipairs(INSERTERS) do
    for _, pair in ipairs({ { "chest", "chest" }, { "chest", "moving belt" }, { "moving belt", "chest" }, { "standing belt", "chest" } }) do
      storage.cases[#storage.cases + 1] = case(x, inserter, pair[1], pair[2])
      x = x + 14
    end
  end

  -- 2. Soil extractors (7x7, facing north: port 3.8 tiles below the centre).
  local ex1 = place({ name = "soil-extractor-mk01", position = { 0.5, 40.5 }, direction = N, recipe = "extract-limestone-01" }, "extractor 1")
  local foundry = place({ name = "advanced-foundry-mk01", position = { 1, 47 }, recipe = "steel-plate" }, "foundry")
  local ex2 = place({ name = "soil-extractor-mk01", position = { 20.5, 40.5 }, direction = N, recipe = "extract-limestone-01" }, "extractor 2")
  for bx = 17, 24 do place({ name = "transport-belt", position = { bx + 0.5, 44.5 }, direction = E }, "port belt") end
  for _, px in pairs({ 5.5, 25.5 }) do
    place({ name = "medium-electric-pole", position = { px, 40.5 } }, "pole")
    local eei = place({ name = "electric-energy-interface", position = { px + 2.5, 40 } }, "power")
    if eei then eei.electric_buffer_size = 1e9; eei.power_production = 1e7 end
  end
  storage.port = { ex1 = ex1, foundry = foundry, ex2 = ex2 }
  out("extractor 1 drop position (%.1f, %.1f), drop target %s", ex1.drop_position.x, ex1.drop_position.y,
    ex1.drop_target and ex1.drop_target.name or "none")
  out("extractor 2 drop position (%.1f, %.1f), drop target %s", ex2.drop_position.x, ex2.drop_position.y,
    ex2.drop_target and ex2.drop_target.name or "none")
end)

script.on_event(defines.events.on_tick, function(event)
  local port = storage.port
  for _, ex in pairs({ port.ex1, port.ex2 }) do ex.insert_fluid({ name = "water", amount = 100 }) end
  if event.tick == WARM then
    for _, c in pairs(storage.cases) do c.start = count(c) end
  elseif event.tick == WARM + T then
    for _, c in pairs(storage.cases) do
      out("%s: %.3f items/s (status %s)", c.label, (count(c) - c.start) / (T / 60), STATUS[c.ins.status] or "?")
    end
    out("foundry fed by extractor 1's port: %d limestone inside, extractor status %s",
      port.foundry.get_item_count("limestone"), STATUS[port.ex1.status] or "?")
    local lanes = {}
    for bx = 17, 24 do
      local b = game.surfaces.nauvis.find_entity("transport-belt", { bx + 0.5, 44.5 })
      for line = 1, 2 do lanes[line] = (lanes[line] or 0) + b.get_transport_line(line).get_item_count("limestone") end
    end
    out("belt under extractor 2's port (flowing east): left lane %d, right lane %d limestone", lanes[1], lanes[2])
    out("DONE")
  end
end)
