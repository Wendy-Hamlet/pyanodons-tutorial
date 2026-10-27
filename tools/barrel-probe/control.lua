-- Measures a row of Auog paddocks and its Water barrel loop inside a copy of a save
-- (tools/save-probe.ps1), and tests how many barrels the loop needs.
-- Variant "MODE[,n:N][,X1:Y1:X2:Y2][,STEP]":
--   "belt"    the loop as built (Barreling Machine, belts, inserters); "n:N" is ignored.
--   "instant" an endless-speed loop: when the save loads, every barrel on the area's belts, in its
--             inserters' hands and in its Barreling Machines is taken away, the Barreling Machines
--             and the inserters filtered to Empty barrels are stopped, and the script then moves
--             barrels itself every tick: the Empty barrels a paddock puts out become Water barrels
--             at once and go to the paddock with the fewest in its input, up to LIMIT (the most an
--             inserter puts in, 10 for 5 a craft). "n:N" sets the barrels in the loop: the ones
--             in the paddocks' inputs and outputs, the 5 inside every running craft, and a spare
--             pool; default: as many as were in the loop.
--   The area defaults to the author's paddock row (2026-10-27 save); STEP to 600 seconds.
-- Every step it prints the Manure made per second, how the paddocks spent the step (a shortage
-- with the ingredients below one craft's worth: barrels, flora, moss), and where the barrels were
-- on average (inputs, running crafts, outputs, belts, inserters, machines, pool).

local variant = require("variant")
local MODE, N, STEP = "belt", nil, 600
local AREA = { { -62, -420 }, { 2, -394 } }
local LIMIT = 10
for field in (variant .. ","):gmatch("([^,]*),") do
  local a1, b1, a2, b2 = field:match("^([%-%d%.]+):([%-%d%.]+):([%-%d%.]+):([%-%d%.]+)$")
  if a1 then AREA = { { tonumber(a1), tonumber(b1) }, { tonumber(a2), tonumber(b2) } }
  elseif field:match("^n:%d+$") then N = tonumber(field:sub(3))
  elseif tonumber(field) then STEP = tonumber(field)
  elseif field == "belt" or field == "instant" then MODE = field
  end
end

local function out(fmt, ...) log("CF-BARREL " .. string.format(fmt, ...)) end
local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end
local BARRELS = { "water-barrel", "barrel" }

local function find(type_or_name)
  return game.surfaces.nauvis.find_entities_filtered({ area = AREA, type = type_or_name.type,
    name = type_or_name.name })
end

local function inv_count(e, kind)
  local inv = e.get_inventory(defines.inventory[kind])
  if not inv then return 0 end
  return inv.get_item_count("water-barrel") + inv.get_item_count("barrel")
end

-- 5 Water barrels are inside a running craft (taken at its start, given back empty at its end).
local function in_craft(p) return (p.is_crafting() and p.crafting_progress < 1) and 5 or 0 end

local function where()
  local w = { inputs = 0, crafts = 0, outputs = 0, belts = 0, hands = 0, machines = 0,
    pool = storage.pool or 0 }
  for _, p in pairs(storage.paddocks) do
    w.inputs = w.inputs + inv_count(p, "crafter_input")
    w.outputs = w.outputs + inv_count(p, "crafter_output")
    w.crafts = w.crafts + in_craft(p)
  end
  for _, b in pairs(find({ type = { "transport-belt", "underground-belt", "splitter" } })) do
    for i = 1, b.get_max_transport_line_index() do
      local line = b.get_transport_line(i)
      for _, name in pairs(BARRELS) do w.belts = w.belts + line.get_item_count(name) end
    end
  end
  for _, ins in pairs(find({ type = "inserter" })) do
    local s = ins.held_stack
    if s.valid_for_read and (s.name == "water-barrel" or s.name == "barrel") then
      w.hands = w.hands + s.count
    end
  end
  for _, m in pairs(find({ name = "barrel-machine-mk01" })) do
    w.machines = w.machines + inv_count(m, "crafter_input") + inv_count(m, "crafter_output")
  end
  w.total = w.inputs + w.crafts + w.outputs + w.belts + w.hands + w.machines + w.pool
  return w
end

local function show(label, w)
  out("%s: %d barrels: inputs %.1f, running crafts %.1f, outputs %.1f, belts %.1f, inserters %.1f, machines %.1f, pool %.1f",
    label, w.total, w.inputs, w.crafts, w.outputs, w.belts, w.hands, w.machines, w.pool)
end

script.on_init(function()
  storage.paddocks = find({ name = "auog-paddock-mk01" })
  storage.pool = 0
  local before = where()
  out("%s mode, %d paddocks, area %d:%d:%d:%d", MODE, #storage.paddocks, AREA[1][1], AREA[1][2],
    AREA[2][1], AREA[2][2])
  show("in the save", before)
  if MODE == "instant" then
    for _, b in pairs(find({ type = { "transport-belt", "underground-belt", "splitter" } })) do
      for i = 1, b.get_max_transport_line_index() do
        local line = b.get_transport_line(i)
        for _, name in pairs(BARRELS) do line.remove_item({ name = name, count = 1000 }) end
      end
    end
    for _, ins in pairs(find({ type = "inserter" })) do
      local s = ins.held_stack
      if s.valid_for_read and (s.name == "water-barrel" or s.name == "barrel") then s.clear() end
      local f = ins.use_filters and ins.get_filter(1)
      if f and (type(f) == "table" and f.name or f) == "barrel" then
        ins.disabled_by_script = true
      end
    end
    for _, m in pairs(find({ name = "barrel-machine-mk01" })) do
      for _, kind in pairs({ "crafter_input", "crafter_output" }) do
        local inv = m.get_inventory(defines.inventory[kind])
        if inv then inv.clear() end
      end
      m.disabled_by_script = true
    end
    -- The loop holds N: what the paddocks hold now, and the rest in the pool.
    local w = where()
    local want = N or before.total
    local held = w.inputs + w.crafts + w.outputs
    storage.pool = want - held
    if storage.pool < 0 then
      -- Fewer barrels than the paddocks hold: take Water barrels out of their inputs.
      local take = -storage.pool
      for _, p in pairs(storage.paddocks) do
        local inv = p.get_inventory(defines.inventory.crafter_input)
        take = take - inv.remove({ name = "water-barrel", count = take })
      end
      storage.pool = 0
    end
    show("set", where())
  end
  storage.start = game.tick
  storage.made0 = game.forces.player.get_item_production_statistics("nauvis").get_input_count("manure")
  storage.sum, storage.samples, storage.status = {}, 0, {}
end)

local function shuttle()
  for _, p in pairs(storage.paddocks) do
    local inv = p.get_inventory(defines.inventory.crafter_output)
    local n = inv.get_item_count("barrel")
    if n > 0 then storage.pool = storage.pool + inv.remove({ name = "barrel", count = n }) end
  end
  while storage.pool > 0 do
    local best, fewest
    for _, p in pairs(storage.paddocks) do
      local c = p.get_inventory(defines.inventory.crafter_input).get_item_count("water-barrel")
      if c < LIMIT and (not fewest or c < fewest) then best, fewest = p, c end
    end
    if not best then break end
    local put = best.insert({ name = "water-barrel", count = math.min(storage.pool, LIMIT - fewest) })
    if put == 0 then break end
    storage.pool = storage.pool - put
  end
end

script.on_event(defines.events.on_tick, function(event)
  if MODE == "instant" then shuttle() end
  if (event.tick - storage.start) % 60 ~= 0 then return end
  local w = where()
  for k, v in pairs(w) do storage.sum[k] = (storage.sum[k] or 0) + v end
  storage.samples = storage.samples + 1
  for _, p in pairs(storage.paddocks) do
    local s = STATUS[p.status] or "-"
    if s == "item_ingredient_shortage" then
      -- Which ingredient is below one craft's worth (5 Water barrels, 20 Native flora, 10 Moss).
      local inv = p.get_inventory(defines.inventory.crafter_input)
      local short = {}
      if inv.get_item_count("water-barrel") < 5 then short[#short + 1] = "barrels" end
      if inv.get_item_count("native-flora") < 20 then short[#short + 1] = "flora" end
      if inv.get_item_count("moss") < 10 then short[#short + 1] = "moss" end
      s = s .. "(" .. (#short > 0 and table.concat(short, "+") or "?") .. ")"
    end
    storage.status[s] = (storage.status[s] or 0) + 1
  end
  local t = (event.tick - storage.start) / 60
  if t > 0 and t % STEP == 0 then
    local made = game.forces.player.get_item_production_statistics("nauvis").get_input_count("manure")
    local parts, all = {}, 0
    for _, n in pairs(storage.status) do all = all + n end
    for s, n in pairs(storage.status) do parts[#parts + 1] = string.format("%s %d%%", s, n * 100 / all + 0.5) end
    table.sort(parts)
    out("step %d s: Manure %.3f per s; paddocks %s", t, (made - storage.made0) / STEP, table.concat(parts, ", "))
    local avg = {}
    for k, v in pairs(storage.sum) do avg[k] = v / storage.samples end
    show(string.format("step %d s average", t), avg)
    storage.made0, storage.sum, storage.samples, storage.status = made, {}, 0, {}
  end
end)
