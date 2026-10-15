-- Measures the start-up of the author's Vrauk line inside a copy of their save
-- (tools/save-probe.ps1). Vrauk paddocks and Reproductive complexes take Vrauks as modules and do
-- nothing without them (base speed -1), so the line grows only by putting the Vrauks it makes
-- back in.
-- Variant "as-is": nothing is moved. "fill": every minute the Vrauks in the area's chests go into
-- free module slots, as the author's robots fill the module requests: into the paddock with the
-- most Vrauks below 10, unless the cocoons would then run short (one Vrauk in a complex makes
-- cocoons for 20 in paddocks), then into a complex. Further fields: a number sets the print step
-- in seconds (default 300); "detail" also prints the complexes' inputs and every belt tile with
-- barrels on it; "X1:Y1:X2:Y2" sets the area (default the author's line, 2026-10-15 save).
-- What-ifs, applied when the save loads: "prio" gives every splitter that has a belt on one
-- output only the output priority on that side, unless an inserter picks from the other side
-- (a splitter keeps 4 items on an output without a belt, tools/belt-lab); "barrels:N" adds N
-- water barrels, half into each complex.
-- Every step it prints Vrauks, cocoons and water barrels made, the Vrauks placed, how the
-- complexes, the paddocks with Vrauks and the barrel machine spent the step, and where the
-- barrels and cocoons are.

local variant = require("variant")
local mode, STEP, DETAIL, PRIO, BARRELS = "as-is", 300, false, false, 0
local AREA = { { -70, -345 }, { 70, -295 } }
local i = 0
for field in (variant .. ","):gmatch("([^,]*),") do
  i = i + 1
  local a1, b1, a2, b2 = field:match("^([%-%d]+):([%-%d]+):([%-%d]+):([%-%d]+)$")
  if a1 then AREA = { { tonumber(a1), tonumber(b1) }, { tonumber(a2), tonumber(b2) } }
  elseif tonumber(field) then STEP = tonumber(field)
  elseif field == "detail" then DETAIL = true
  elseif field == "prio" then PRIO = true
  elseif field:match("^barrels:%d+$") then BARRELS = tonumber(field:match("%d+"))
  elseif i == 1 and field ~= "" then mode = field end
end
local PADDOCK, COMPLEX, BARRELER = "vrauks-paddock-mk01", "rc-mk01", "barrel-machine-mk01"
local PER_COMPLEX = 20 -- cocoons one complex Vrauk makes / cocoons one paddock Vrauk uses

local function out(fmt, ...) log("CF-VRAUK " .. string.format(fmt, ...)) end
local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end

local function find(filter)
  filter.area, filter.force = AREA, "player"
  return game.surfaces.nauvis.find_entities_filtered(filter)
end

local function modules(e)
  return e.get_module_inventory().get_item_count("vrauks")
end

-- Barrel recipes are left out of the production statistics: water barrels are counted as the
-- barrel machines' finished crafts instead.
local function made(name)
  if name == "water-barrel" then
    local n = 0
    for _, b in pairs(find({ name = BARRELER })) do n = n + b.products_finished end
    return n
  end
  return game.forces.player.get_item_production_statistics(game.surfaces.nauvis).get_input_count(name)
end

-- Where the water barrels, empty barrels and cocoons are, by holder kind.
local function census()
  local where = {}
  local function add(kind, inv_or_counts)
    local w = where[kind] or { water = 0, empty = 0, cocoon = 0 }
    where[kind] = w
    w.water = w.water + inv_or_counts("water-barrel")
    w.empty = w.empty + inv_or_counts("barrel")
    w.cocoon = w.cocoon + inv_or_counts("cocoon")
  end
  for _, e in pairs(find({ type = { "assembling-machine", "furnace" } })) do
    local kind = e.name == PADDOCK and "paddocks" or e.name == COMPLEX and "complexes" or e.name == BARRELER and "barreler" or nil
    if kind then
      for _, i in ipairs({ defines.inventory.crafter_input, defines.inventory.crafter_output }) do
        local inv = e.get_inventory(i)
        add(kind, function(n) return inv.get_item_count(n) end)
      end
    end
  end
  for _, e in pairs(find({ type = { "transport-belt", "underground-belt", "splitter" } })) do
    for line = 1, e.get_max_transport_line_index() do
      local tl = e.get_transport_line(line)
      add("belts", function(n) return tl.get_item_count(n) end)
    end
  end
  for _, e in pairs(find({ type = "inserter" })) do
    local h = e.held_stack
    add("hands", function(n) return (h.valid_for_read and h.name == n) and h.count or 0 end)
  end
  for _, e in pairs(find({ type = "container" })) do
    local inv = e.get_inventory(defines.inventory.chest)
    add("chests", function(n) return inv.get_item_count(n) end)
  end
  local parts, total = {}, 0
  for _, k in ipairs({ "paddocks", "complexes", "barreler", "belts", "hands", "chests" }) do
    local w = where[k] or { water = 0, empty = 0, cocoon = 0 }
    parts[#parts + 1] = string.format("%s %d+%d/%d", k, w.water, w.empty, w.cocoon)
    total = total + w.water + w.empty
  end
  return table.concat(parts, ", "), total
end

-- Moves the chests' Vrauks into module slots; returns how many went in.
local function fill()
  local stock, chests = 0, find({ type = "container" })
  for _, c in pairs(chests) do stock = stock + c.get_item_count("vrauks") end
  if stock == 0 then return 0 end
  local paddocks, complexes = find({ name = PADDOCK }), find({ name = COMPLEX })
  local placed = 0
  while stock > 0 do
    local in_paddocks, in_complexes = 0, 0
    for _, p in pairs(paddocks) do in_paddocks = in_paddocks + modules(p) end
    for _, c in pairs(complexes) do in_complexes = in_complexes + modules(c) end
    local target
    if in_paddocks + 1 > PER_COMPLEX * in_complexes then
      for _, c in pairs(complexes) do if modules(c) < 2 then target = c break end end
    end
    if not target then
      for _, p in pairs(paddocks) do
        local m = modules(p)
        if m < 10 and (not target or m > modules(target)) then target = p end
      end
    end
    if not target then
      for _, c in pairs(complexes) do if modules(c) < 2 then target = c break end end
    end
    if not target then break end
    target.get_module_inventory().insert({ name = "vrauks", count = 1 })
    for _, c in pairs(chests) do
      if c.remove_item({ name = "vrauks", count = 1 }) == 1 then break end
    end
    stock, placed = stock - 1, placed + 1
  end
  return placed
end

local function sample(key, e)
  local g = storage.samples[key] or {}
  storage.samples[key] = g
  local s = STATUS[e.status] or "?"
  g[s] = (g[s] or 0) + 1
end

local function usual(key)
  local g, best, n, total = storage.samples[key], nil, 0, 0
  if not g then return "-" end
  for s, c in pairs(g) do
    total = total + c
    if c > n then best, n = s, c end
  end
  return string.format("%s %.0f%%", best, 100 * n / total)
end

-- Output priority on the side of a splitter's only output belt (see "prio" above).
local VEC = { [defines.direction.north] = { 0, -1 }, [defines.direction.east] = { 1, 0 },
  [defines.direction.south] = { 0, 1 }, [defines.direction.west] = { -1, 0 } }
local function set_priorities()
  local changed, skipped = {}, {}
  local pickups = {}
  for _, i in pairs(find({ type = "inserter" })) do pickups[#pickups + 1] = i.pickup_position end
  for _, s in pairs(find({ type = "splitter" })) do
    local outs = s.belt_neighbours.outputs or {}
    local v = VEC[s.direction]
    if #outs == 1 and v then
      local left = { v[2], -v[1] } -- the splitter's left, seen in its direction
      local o, p = outs[1].position, s.position
      local side = ((o.x - p.x) * left[1] + (o.y - p.y) * left[2]) > 0 and "left" or "right"
      local sign = side == "left" and -1 or 1 -- the side without a belt
      local tx, ty = p.x + sign * 0.5 * left[1], p.y + sign * 0.5 * left[2]
      local used = false
      for _, q in ipairs(pickups) do
        if math.abs(q.x - tx) < 0.5 and math.abs(q.y - ty) < 0.5 then used = true end
      end
      local at = p.x .. "," .. p.y
      if used then skipped[#skipped + 1] = at
      else
        s.splitter_output_priority = side
        changed[#changed + 1] = at .. " " .. side
      end
    end
  end
  out("prio: output priority set on %s; left alone (an inserter picks from the other side): %s",
    table.concat(changed, " | "), table.concat(skipped, " | "))
end

script.on_init(function()
  if PRIO then set_priorities() end
  if BARRELS > 0 then
    local complexes = find({ name = COMPLEX })
    for n, c in ipairs(complexes) do
      local share = math.floor(BARRELS / #complexes) + ((n <= BARRELS % #complexes) and 1 or 0)
      out("barrels: %d water barrels into the complex at %s,%s", c.get_inventory(defines.inventory.crafter_input).insert({ name = "water-barrel", count = share }), c.position.x, c.position.y)
    end
  end
  storage.seconds, storage.samples, storage.placed = 0, {}, 0
  storage.before = { vrauks = made("vrauks"), cocoon = made("cocoon"), ["water-barrel"] = made("water-barrel"), moss = made("moss") }
  local mp, mc = 0, 0
  for _, p in pairs(find({ name = PADDOCK })) do mp = mp + modules(p) end
  for _, c in pairs(find({ name = COMPLEX })) do mc = mc + modules(c) end
  local where, total = census()
  out("mode %s, step %d s; Vrauks in paddocks %d, in complexes %d; water+empty barrels/cocoons: %s; barrels seen %d", mode, STEP, mp, mc, where, total)
end)

script.on_nth_tick(60, function()
  storage.seconds = storage.seconds + 1
  local t = storage.seconds
  local paddocks, complexes = find({ name = PADDOCK }), find({ name = COMPLEX })
  for _, c in pairs(complexes) do sample("complexes", c) end
  for _, p in pairs(paddocks) do if modules(p) > 0 then sample("paddocks with Vrauks", p) end end
  for _, b in pairs(find({ name = BARRELER })) do sample("barreler", b) end
  if mode == "fill" and t % 60 == 0 then storage.placed = storage.placed + fill() end
  if t % STEP ~= 0 then return end
  local mp, mc, full = 0, 0, 0
  for _, p in pairs(paddocks) do
    mp = mp + modules(p)
    if modules(p) == 10 then full = full + 1 end
  end
  for _, c in pairs(complexes) do mc = mc + modules(c) end
  local d = {}
  for name, before in pairs(storage.before) do
    local now = made(name)
    d[name] = now - before
    storage.before[name] = now
  end
  local where, total = census()
  out("%d min: made Vrauks %d, cocoons %d, water barrels %d, moss %d; placed %d; Vrauks in paddocks %d (%d full), in complexes %d; complexes %s, paddocks with Vrauks %s, barreler %s; water+empty barrels/cocoons: %s; barrels seen %d",
    t / 60, d.vrauks, d.cocoon, d["water-barrel"], d.moss, storage.placed, mp, full, mc,
    usual("complexes"), usual("paddocks with Vrauks"), usual("barreler"), where, total)
  if DETAIL then
    for _, c in pairs(complexes) do
      local parts = {}
      for _, item in pairs(c.get_inventory(defines.inventory.crafter_input).get_contents()) do
        parts[#parts + 1] = item.name .. " " .. item.count
      end
      out("  complex at %s,%s: %s; input %s", c.position.x, c.position.y, STATUS[c.status], table.concat(parts, ", "))
    end
    local tiles = {}
    for _, e in pairs(find({ type = { "transport-belt", "underground-belt", "splitter" } })) do
      local w, em = 0, 0
      for line = 1, e.get_max_transport_line_index() do
        local tl = e.get_transport_line(line)
        w, em = w + tl.get_item_count("water-barrel"), em + tl.get_item_count("barrel")
      end
      if w + em > 0 then tiles[#tiles + 1] = string.format("%s,%s %d+%d", e.position.x, e.position.y, w, em) end
    end
    out("  belt tiles with water+empty barrels: %s", table.concat(tiles, " | "))
  end
  if not storage.all_full and mp + mc == 10 * #paddocks + 2 * #complexes then
    storage.all_full = true
    out("all %d module slots full at %d min", mp + mc, t / 60)
  end
  storage.samples, storage.placed = {}, 0
end)
