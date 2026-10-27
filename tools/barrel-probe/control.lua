-- Measures a row of Auog paddocks and its Water barrel loop inside a copy of a save
-- (tools/save-probe.ps1), and tests how many barrels the loop needs.
-- Variant "MODE[,n:N][,feed][,jam:T1:T2][,X1:Y1:X2:Y2][,STEP]":
--   "belt"    the loop as built (Barreling Machine, belts, inserters); "n:N" is ignored.
--   "instant" an endless-speed loop: when the save loads, every barrel on the area's belts, in its
--             inserters' hands and in its Barreling Machines is taken away, the Barreling Machines
--             and the inserters filtered to Empty barrels are stopped, and the script then moves
--             barrels itself every tick: the Empty barrels a paddock puts out become Water barrels
--             at once and go, like on the belt, to the first paddock along the belt from the
--             Barreling Machine whose input holds fewer than LIMIT (the most an inserter puts in,
--             10 for 5 a craft). "n:N" sets the barrels in the loop: the ones in the paddocks'
--             inputs and outputs, the 5 inside every running craft, and a spare pool; default: as
--             many as were in the loop.
--   "jam:T1:T2" stops the inserters that take Manure out of the paddocks from T1 to T2 seconds
--             (the battery line standing), so the paddocks fill up and stop, then start again.
--   "feed"    tops up every paddock's Native flora (40) and Moss (20) once a second, so that only
--             the barrels can hold the paddocks back (a what-if; the items come from nothing).
--   The area defaults to the author's paddock row (2026-10-27 save); STEP to 600 seconds.
-- At the start it prints the paddocks in belt order and the inserters taking out of each (Manure
-- or barrels).
-- Every step it prints the Manure made per second, how the paddocks spent the step (a shortage
-- with the ingredients below one craft's worth: barrels, flora, moss), and where the barrels were
-- on average (inputs, running crafts, outputs, belts, inserters, machines, pool).

local variant = require("variant")
local MODE, N, STEP, JAM, FEED = "belt", nil, 600, nil, false
local AREA = { { -62, -420 }, { 2, -394 } }
local LIMIT = 10
for field in (variant .. ","):gmatch("([^,]*),") do
  local a1, b1, a2, b2 = field:match("^([%-%d%.]+):([%-%d%.]+):([%-%d%.]+):([%-%d%.]+)$")
  local j1, j2 = field:match("^jam:(%d+):(%d+)$")
  if a1 then AREA = { { tonumber(a1), tonumber(b1) }, { tonumber(a2), tonumber(b2) } }
  elseif j1 then JAM = { tonumber(j1), tonumber(j2) }
  elseif field == "feed" then FEED = true
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

local BELTS = { ["transport-belt"] = true, ["underground-belt"] = true, ["splitter"] = true }

local function near_area(e)
  local p = e.position
  return p.x >= AREA[1][1] - 8 and p.x <= AREA[2][1] + 8 and p.y >= AREA[1][2] - 8 and p.y <= AREA[2][2] + 8
end

-- Steps along the belts from the ones the Barreling Machines' inserters drop on (breadth first,
-- through Undergrounds and Splitters, near the area only).
local function belt_steps()
  local steps, queue, head = {}, {}, 1
  for _, ins in pairs(find({ type = "inserter" })) do
    local from, to = ins.pickup_target, ins.drop_target
    if from and from.name == "barrel-machine-mk01" and to and BELTS[to.type] then
      steps[to.unit_number] = 0
      queue[#queue + 1] = to
    end
  end
  while queue[head] do
    local b = queue[head]
    head = head + 1
    local nexts = {}
    for _, n in pairs(b.belt_neighbours.outputs) do nexts[#nexts + 1] = n end
    if b.type == "underground-belt" and b.belt_to_ground_type == "input" and b.underground_belt_neighbour then
      nexts[#nexts + 1] = b.underground_belt_neighbour
    end
    for _, n in pairs(nexts) do
      if not steps[n.unit_number] and near_area(n) then
        steps[n.unit_number] = steps[b.unit_number] + 1
        queue[#queue + 1] = n
      end
    end
  end
  return steps
end

local function where_is(e)
  if not e then return "-" end
  return string.format("%s(%.1f,%.1f)", e.name, e.position.x, e.position.y)
end

-- The paddocks in the order the Water barrels pass them: by the first belt step any inserter
-- feeding the paddock picks up from. Of the inserters taking out of a paddock, the ones dropping
-- on the barrel loop carry its Empty barrels, the others its Manure (the ones a jam stops).
local function order_paddocks()
  local steps = belt_steps()
  local first, outs = {}, {}
  storage.manure_out = {}
  for _, ins in pairs(find({ type = "inserter" })) do
    local from, to = ins.pickup_target, ins.drop_target
    for i, p in pairs(storage.paddocks) do
      if to == p and from and BELTS[from.type] and steps[from.unit_number] then
        first[i] = math.min(first[i] or math.huge, steps[from.unit_number])
      end
      if from == p then
        outs[i] = outs[i] or {}
        outs[i][#outs[i] + 1] = ins
        if not (to and steps[to.unit_number]) then storage.manure_out[#storage.manure_out + 1] = ins end
      end
    end
  end
  local list = {}
  for i, p in pairs(storage.paddocks) do
    list[#list + 1] = { p = p, step = first[i] or math.huge, outs = outs[i] or {} }
  end
  table.sort(list, function(a, b) return a.step < b.step end)
  storage.paddocks = {}
  for k, x in ipairs(list) do
    storage.paddocks[k] = x.p
    local o = {}
    for _, ins in pairs(x.outs) do
      local manure = false
      for _, m in pairs(storage.manure_out) do if m == ins then manure = true end end
      o[#o + 1] = where_is(ins) .. "->" .. where_is(ins.drop_target) .. (manure and " (Manure)" or " (barrels)")
    end
    out("paddock %d at (%.0f,%.0f): belt step %s; out: %s", k, x.p.position.x, x.p.position.y,
      tostring(x.step), table.concat(o, ", "))
  end
end

local function jam(on)
  for _, ins in pairs(storage.manure_out) do ins.disabled_by_script = on end
  out("jam %s at %d s (%d Manure inserters)", on and "on" or "off", (game.tick - storage.start) / 60,
    #storage.manure_out)
end

script.on_init(function()
  storage.paddocks = find({ name = "auog-paddock-mk01" })
  storage.pool = 0
  order_paddocks()
  local before = where()
  out("%s mode, %d paddocks, area %d:%d:%d:%d%s", MODE, #storage.paddocks, AREA[1][1], AREA[1][2],
    AREA[2][1], AREA[2][2], (JAM and string.format(", jam %d-%d s", JAM[1], JAM[2]) or "") ..
    (FEED and ", fed" or ""))
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
        if take <= 0 then break end
        local inv = p.get_inventory(defines.inventory.crafter_input)
        take = take - inv.remove({ name = "water-barrel", count = take })
      end
      storage.pool = 0
    end
    show("set", where())
  end
  storage.start = game.tick
  storage.made0 = game.forces.player.get_item_production_statistics("nauvis").get_input_count("manure")
  storage.sum, storage.samples, storage.status, storage.busy = {}, 0, {}, {}
end)

local function shuttle()
  for _, p in pairs(storage.paddocks) do
    local inv = p.get_inventory(defines.inventory.crafter_output)
    local n = inv.get_item_count("barrel")
    if n > 0 then storage.pool = storage.pool + inv.remove({ name = "barrel", count = n }) end
  end
  for _, p in ipairs(storage.paddocks) do
    if storage.pool <= 0 then break end
    local c = p.get_inventory(defines.inventory.crafter_input).get_item_count("water-barrel")
    if c < LIMIT then
      storage.pool = storage.pool - p.insert({ name = "water-barrel", count = math.min(storage.pool, LIMIT - c) })
    end
  end
end

script.on_event(defines.events.on_tick, function(event)
  if MODE == "instant" then shuttle() end
  if JAM then
    local t = event.tick - storage.start
    if t == JAM[1] * 60 then jam(true) elseif t == JAM[2] * 60 then jam(false) end
  end
  if (event.tick - storage.start) % 60 ~= 0 then return end
  local w = where()
  for k, v in pairs(w) do storage.sum[k] = (storage.sum[k] or 0) + v end
  storage.samples = storage.samples + 1
  for k, p in ipairs(storage.paddocks) do
    local s = STATUS[p.status] or "-"
    if s == "working" then storage.busy[k] = (storage.busy[k] or 0) + 1 end
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
  if FEED then
    for _, p in pairs(storage.paddocks) do
      local inv = p.get_inventory(defines.inventory.crafter_input)
      for name, want in pairs({ ["native-flora"] = 40, moss = 20 }) do
        local n = want - inv.get_item_count(name)
        if n > 0 then p.insert({ name = name, count = n }) end
      end
    end
  end
  local t = (event.tick - storage.start) / 60
  if t > 0 and t % STEP == 0 then
    local made = game.forces.player.get_item_production_statistics("nauvis").get_input_count("manure")
    local parts, all = {}, 0
    for _, n in pairs(storage.status) do all = all + n end
    for s, n in pairs(storage.status) do parts[#parts + 1] = string.format("%s %d%%", s, n * 100 / all + 0.5) end
    table.sort(parts)
    out("step %d s: Manure %.3f per s; paddocks %s", t, (made - storage.made0) / STEP, table.concat(parts, ", "))
    local each = {}
    for k = 1, #storage.paddocks do each[k] = string.format("%d%%", (storage.busy[k] or 0) * 100 / storage.samples + 0.5) end
    out("step %d s: working, in belt order: %s", t, table.concat(each, " "))
    local avg = {}
    for k, v in pairs(storage.sum) do avg[k] = v / storage.samples end
    show(string.format("step %d s average", t), avg)
    storage.made0, storage.sum, storage.samples, storage.status, storage.busy = made, {}, 0, {}, {}
  end
end)
