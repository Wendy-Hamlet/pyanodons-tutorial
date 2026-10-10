-- The Mechanical inserter's rate to three decimals, in the cases designs use: from a chest, a
-- moving full belt or a standing full belt (the end of a belt), both lanes full or only one (the
-- one nearer the inserter or the far one, filled by script), into a chest, a moving belt, a
-- Burner assembling machine or a Stone furnace whose recipe wants far more than one inserter
-- brings. Every case runs for 10 minutes after a warm-up; the probe counts each drop (the held
-- stack emptying) and the tick it happens, so the rate is both drops per second and 60 / the
-- average ticks between drops. Results are CF-RATE log lines.

local N, E = defines.direction.north, defines.direction.east
local WARM, T = 600, 36000
local INSERTER = "burner-inserter"

local function out(fmt, ...) log("CF-RATE " .. string.format(fmt, ...)) end
local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end

local surface
local function place(spec, what)
  spec.force = "player"
  local e = surface.create_entity(spec)
  if not e then out("FIXTURE FAILED: %s", what) end
  return e
end

-- Belt from x1 to x2 on row y flowing east, fed full by a loader from an infinity chest (or, with
-- `lane`, only that lane, by script every tick); with `moving`, a loader at the far end takes
-- everything into an infinity chest set to empty itself.
local function belt_row(x1, x2, y, item, fed, moving, lane)
  local first
  for x = x1, x2 do
    local b = place({ name = "transport-belt", position = { x + 0.5, y + 0.5 }, direction = E }, "belt")
    first = first or b
  end
  if lane then
    storage.lane_feeds[#storage.lane_feeds + 1] = { belt = first, line = lane, item = item }
  elseif fed then
    place({ name = "loader", position = { x1 - 1, y + 0.5 }, direction = E, type = "output" }, "source loader")
    local c = place({ name = "infinity-chest", position = { x1 - 2.5, y + 0.5 } }, "source chest")
    c.set_infinity_container_filter(1, { name = item, count = 50, mode = "exactly" })
  end
  if moving then
    place({ name = "loader", position = { x2 + 2, y + 0.5 }, direction = E, type = "input" }, "sink loader")
    local c = place({ name = "infinity-chest", position = { x2 + 3.5, y + 0.5 } }, "sink chest")
    c.remove_unfiltered_items = true
  end
end

-- One Mechanical inserter at (x, 0) with the given source behind it and target in front.
local function case(x, from, to, item, recipe, lane)
  local ins = place({ name = INSERTER, position = { x + 0.5, 0.5 }, direction = N }, INSERTER)
  local p, d = ins.pickup_position, ins.drop_position
  local px, py, dx, dy = math.floor(p.x), math.floor(p.y), math.floor(d.x), math.floor(d.y)
  local ahead = dy < 0 and -1 or 1 -- the side the target lies on
  local c = { label = string.format("%s -> %s (%s)", from, to, item), ins = ins, prev = 0, n = 0, status = {} }
  if from == "chest" then
    local src = place({ name = "infinity-chest", position = { px + 0.5, py + 0.5 } }, "source chest")
    src.set_infinity_container_filter(1, { name = item, count = 50, mode = "exactly" })
  else
    belt_row(px - 2, px + 2, py, item, true, from == "moving belt", lane)
    if lane then
      -- Line 1 is the left lane looking east, i.e. the north one.
      local near = (py > math.floor(ins.position.y)) == (lane == 1)
      c.label = string.format("%s, only the %s lane -> %s (%s)", from, near and "near" or "far", to, item)
    end
  end
  if to == "chest" then
    local sink = place({ name = "infinity-chest", position = { dx + 0.5, dy + 0.5 } }, "sink chest")
    sink.remove_unfiltered_items = true
  elseif to == "moving belt" then
    belt_row(dx - 2, dx + 2, dy, item, false, true)
  elseif to == "assembler" then
    c.machine = place({ name = "assembling-machine-1", position = { dx + 0.5, dy + 0.5 + ahead }, recipe = recipe }, "assembler")
  elseif to == "furnace" then
    c.machine = place({ name = "stone-furnace", position = { dx + 1, dy + (ahead < 0 and 0 or 1) } }, "furnace")
  end
  if c.machine then c.label = c.label .. " " .. recipe end
  return c
end

local function service(m)
  local fuel = m.get_fuel_inventory()
  if fuel.get_item_count("raw-coal") < 20 then fuel.insert({ name = "raw-coal", count = 50 }) end
  m.get_output_inventory().clear()
  local burnt = m.get_burnt_result_inventory()
  if burnt then burnt.clear() end
end

script.on_init(function()
  surface = game.surfaces.nauvis
  surface.request_to_generate_chunks({ 0, 0 }, 4)
  surface.force_generate_chunk_requests()
  for _, e in pairs(surface.find_entities({ { -120, -120 }, { 120, 120 } })) do if e.valid then e.destroy() end end
  local tiles = {}
  for x = -120, 119 do for y = -120, 119 do tiles[#tiles + 1] = { name = "lab-dark-1", position = { x, y } } end end
  surface.set_tiles(tiles)
  for _, r in pairs({ "aluminium-plate-1", "iron-oxide-smelting" }) do game.forces.player.recipes[r].enabled = true end

  storage.cases, storage.lane_feeds = {}, {}
  local x = -100
  for _, spec in ipairs({
    { "chest", "chest", "iron-plate" },
    { "chest", "moving belt", "iron-plate" },
    { "moving belt", "chest", "iron-plate" },
    { "standing belt", "chest", "iron-plate" },
    { "chest", "assembler", "iron-plate", "iron-gear-wheel" },
    { "moving belt", "assembler", "iron-plate", "iron-gear-wheel" },
    { "standing belt", "assembler", "iron-plate", "iron-gear-wheel" },
    { "chest", "furnace", "ore-aluminium", "aluminium-plate-1" },
    { "standing belt", "furnace", "ore-aluminium", "aluminium-plate-1" },
    { "chest", "furnace", "iron-oxide", "iron-oxide-smelting" },
    { "standing belt", "furnace", "iron-oxide", "iron-oxide-smelting" },
    { "standing belt", "chest", "iron-plate", nil, 1 },
    { "standing belt", "chest", "iron-plate", nil, 2 },
    { "moving belt", "chest", "iron-plate", nil, 1 },
    { "moving belt", "chest", "iron-plate", nil, 2 },
  }) do
    storage.cases[#storage.cases + 1] = case(x, spec[1], spec[2], spec[3], spec[4], spec[5])
    x = x + 14
  end
  for _, c in pairs(storage.cases) do if c.machine then service(c.machine) end end
end)

script.on_event(defines.events.on_tick, function(event)
  local t = event.tick
  for _, f in pairs(storage.lane_feeds) do f.belt.get_transport_line(f.line).insert_at_back({ name = f.item, count = 1 }) end
  for _, c in pairs(storage.cases) do
    if c.machine and t % 60 == 0 then service(c.machine) end
    local h = c.ins.held_stack
    local now = h.valid_for_read and h.count or 0
    if now < c.prev and t > WARM and t <= WARM + T then
      c.n = c.n + (c.prev - now)
      c.first = c.first or t
      c.last = t
    end
    c.prev = now
    if t > WARM and t <= WARM + T and t % 60 == 0 then
      local s = STATUS[c.ins.status] or "?"
      c.status[s] = (c.status[s] or 0) + 1
    end
  end
  if t == WARM + T + 1 then
    for _, c in pairs(storage.cases) do
      local cycle = (c.last - c.first) / (c.n - 1)
      local st = {}
      for k, v in pairs(c.status) do st[#st + 1] = k .. " " .. v end
      table.sort(st)
      local craft = ""
      if c.machine then
        craft = string.format("; machine %s, crafting speed %.2f", STATUS[c.machine.status] or "?", c.machine.crafting_speed)
      end
      out("%s: %d drops in %d s = %.4f items/s; %.4f ticks between drops = %.4f items/s; inserter status samples: %s%s",
        c.label, c.n, T / 60, c.n / (T / 60), cycle, 60 / cycle, table.concat(st, ", "), craft)
    end
    out("DONE")
  end
end)
