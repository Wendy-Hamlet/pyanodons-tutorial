-- Measures a power block where it stands in a copy of the author's save (tools/save-probe.ps1),
-- finished by script where the author has not built it yet: ghosts in the block's box revived,
-- entities placed (poles wired to the nearest pole of the box, regardless of reach), infinity
-- pipes giving water, script sources keeping input belts full on both lanes, sinks emptying output
-- belts, and a load: an energy interface emptied every tick, so it takes whatever the block's
-- electric network has left over and the Steam engines run as hard as their steam allows.
-- The block's network must not be wired to the rest of the base.
-- Every STEP seconds and over the whole measurement it prints the network's power by entity
-- (made and used, MW), what the load took, the crafts of the box's machines, what the sources
-- gave and the sinks took, the items waiting on the box's belts and in its Boilers, and every
-- machine group's statuses (Boilers by row and the fuel they burn).
-- Variant: "WARM,MEASURE,STEP" then ";key=value" fields, lists separated by "|":
--   box=x1:y1:x2:y2          the block
--   src=item@x:y|...         belt tiles kept full of item
--   sink=x:y|...             belt tiles emptied every tick
--   water=x:y|...            infinity pipes of Water
--   place=name@x:y[:dir[:item]]|... entities placed (dir north, east, south, west; default
--                            north; an inserter's direction is the side it picks up from;
--                            item: an inserter's whitelist filter)
--   load=x:y                 the energy interface (2x2; inside a pole's supply area)
--   each=name|...            machines of that name sampled one by one, not as a group
--   prime=item:count         fuel put into every Boiler of the box once (a block that powers its
--                            own crushers cannot start itself)

local variant = require("variant")
local head, rest = variant:match("^([^;]*);?(.*)$")
local WARM, MEASURE, STEP = head:match("^(%d+),(%d+),(%d+)$")
WARM, MEASURE, STEP = tonumber(WARM), tonumber(MEASURE), tonumber(STEP)
local opt = {}
for k, v in rest:gmatch("(%w+)=([^;]*)") do opt[k] = v end
local function list(s)
  local r = {}
  for p in (s or ""):gmatch("[^|]+") do r[#r + 1] = p end
  return r
end
local function num(s) return tonumber(s) end

local function out(fmt, ...) log("CF-POWER " .. string.format(fmt, ...)) end
local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end
local BELTS = { "transport-belt", "underground-belt", "splitter" }

local function belt_at(surface, x, y)
  return surface.find_entities_filtered({ position = { x, y }, type = BELTS })[1]
end

local function nearest_pole(surface, area, pole)
  local best, d
  for _, p in pairs(surface.find_entities_filtered({ area = area, type = "electric-pole" })) do
    if p ~= pole then
      local dd = (p.position.x - pole.position.x) ^ 2 + (p.position.y - pole.position.y) ^ 2
      if not d or dd < d then best, d = p, dd end
    end
  end
  return best
end

script.on_init(function()
  local surface = game.surfaces.nauvis
  local f = game.forces.player
  local x1, y1, x2, y2 = opt.box:match("([%-%.%d]+):([%-%.%d]+):([%-%.%d]+):([%-%.%d]+)")
  local area = { { num(x1), num(y1) }, { num(x2), num(y2) } }
  local bonus = {}
  for _, k in ipairs({ "inserter_stack_size_bonus", "bulk_inserter_capacity_bonus", "belt_stack_size_bonus",
    "mining_drill_productivity_bonus" }) do
    local ok, v = pcall(function() return f[k] end)
    bonus[#bonus + 1] = k .. " " .. tostring(ok and v or "-")
  end
  out("loaded at tick %d; warm %d s, measure %d s, step %d s; force: %s", game.tick, WARM, MEASURE, STEP,
    table.concat(bonus, ", "))

  local revived, failed = {}, {}
  for _, g in pairs(surface.find_entities_filtered({ area = area, type = "entity-ghost" })) do
    local name = g.ghost_name
    local _, e = g.revive()
    local t = e and revived or failed
    t[name] = (t[name] or 0) + 1
  end
  for n, c in pairs(revived) do out("revived %d %s", c, n) end
  for n, c in pairs(failed) do out("could not revive %d %s", c, n) end

  local placed, missed = {}, {}
  for _, p in ipairs(list(opt.place)) do
    local name, x, y, dir, filter = p:match("^([%w%-_]+)@([%-%.%d]+):([%-%.%d]+):?(%a*):?([%w%-_]*)$")
    local e = surface.create_entity({ name = name, position = { num(x), num(y) }, force = f,
      direction = defines.direction[dir ~= "" and dir or "north"] })
    if e then
      placed[name] = (placed[name] or 0) + 1
      if filter ~= "" then
        e.use_filters = true
        e.inserter_filter_mode = "whitelist"
        e.set_filter(1, filter)
      end
      if e.type == "electric-pole" then
        local q = nearest_pole(surface, area, e)
        if q then
          e.get_wire_connector(defines.wire_connector_id.pole_copper, true).connect_to(
            q.get_wire_connector(defines.wire_connector_id.pole_copper, true), false)
        end
      end
    else
      missed[#missed + 1] = p
    end
  end
  for n, c in pairs(placed) do out("placed %d %s", c, n) end
  if #missed > 0 then out("could not place: %s", table.concat(missed, " ")) end

  for _, w in ipairs(list(opt.water)) do
    local x, y = w:match("([%-%.%d]+):([%-%.%d]+)")
    local e = surface.create_entity({ name = "infinity-pipe", position = { num(x), num(y) }, force = f })
    if e then e.set_infinity_pipe_filter({ name = "water", percentage = 1, temperature = 15, mode = "at-least" }) end
    out("water at %s: %s", w, e and "ok" or "FAILED")
  end

  local sources, sinks = {}, {}
  for _, s in ipairs(list(opt.src)) do
    local item, x, y = s:match("^([%w%-_]+)@([%-%.%d]+):([%-%.%d]+)$")
    local e = belt_at(surface, num(x), num(y))
    if e then sources[#sources + 1] = { e = e, item = item, n = 0 } else out("no belt for the source %s", s) end
  end
  for _, s in ipairs(list(opt.sink)) do
    local x, y = s:match("([%-%.%d]+):([%-%.%d]+)")
    local e = belt_at(surface, num(x), num(y))
    if e then sinks[#sinks + 1] = { e = e, at = s } else out("no belt for the sink %s", s) end
  end

  -- A block whose crushers need its own power cannot start itself: prime=item:count puts that
  -- fuel into every Boiler of the box once, as a player would.
  if opt.prime then
    local item, count = opt.prime:match("^([%w%-_]+):(%d+)$")
    local nb = 0
    for _, b in pairs(surface.find_entities_filtered({ area = area, type = "boiler" })) do
      nb = nb + b.get_inventory(defines.inventory.fuel).insert({ name = item, count = num(count) })
    end
    out("primed the Boilers with %d %s", nb, item)
  end

  local x, y = opt.load:match("([%-%.%d]+):([%-%.%d]+)")
  local load = surface.create_entity({ name = "electric-energy-interface", position = { num(x), num(y) }, force = f })
  load.power_usage, load.power_production, load.electric_buffer_size = 0, 0, 1e12

  local poles = surface.find_entities_filtered({ area = area, type = "electric-pole" })
  local nets = {}
  for _, p in pairs(poles) do nets[p.electric_network_id] = (nets[p.electric_network_id] or 0) + 1 end
  local n = {}
  for id, c in pairs(nets) do n[#n + 1] = string.format("%d (%d poles)", id, c) end
  out("networks in the box: %s; load on %s", table.concat(n, ", "), tostring(load.electric_network_id))

  storage.p = {
    surface = surface, area = area, sources = sources, sinks = sinks, load = load, absorbed = 0,
    pole = poles[1], taken = {}, start = game.tick,
    machines = surface.find_entities_filtered({ area = area,
      type = { "assembling-machine", "furnace", "boiler", "generator", "mining-drill" } }),
    belts = surface.find_entities_filtered({ area = area, type = BELTS }),
    fuel = {}, each = {},
  }
  for _, n in ipairs(list(opt.each)) do storage.p.each[n] = true end
end)

local function belt_items(p)
  local r = {}
  for _, e in pairs(p.belts) do
    if e.valid then
      for i = 1, e.get_max_transport_line_index() do
        for _, c in pairs(e.get_transport_line(i).get_contents()) do r[c.name] = (r[c.name] or 0) + c.count end
      end
    end
  end
  return r
end

local function snapshot(p)
  local s = { made = {}, used = {}, crafts = {}, absorbed = p.absorbed, given = {}, taken = {}, tick = game.tick }
  -- An electric network's statistics count what consumers took as input, what generators gave
  -- as output (the other way round from item statistics); energy in J.
  local st = p.pole.electric_network_statistics
  for k, v in pairs(st.output_counts) do s.made[k] = v end
  for k, v in pairs(st.input_counts) do s.used[k] = v end
  for _, e in pairs(p.machines) do
    if e.valid and (e.type == "assembling-machine" or e.type == "furnace") then
      local r = e.get_recipe()
      local k = e.name .. " / " .. (r and r.name or "-")
      s.crafts[k] = (s.crafts[k] or 0) + e.products_finished
    end
  end
  for _, src in ipairs(p.sources) do s.given[src.item] = (s.given[src.item] or 0) + src.n end
  for k, v in pairs(p.taken) do s.taken[k] = v end
  return s
end

local function fmt_rates(a, b, sec, scale, unit)
  local keys = {}
  for k in pairs(a) do keys[#keys + 1] = k end
  table.sort(keys)
  local parts = {}
  for _, k in ipairs(keys) do
    local d = ((a[k] or 0) - (b[k] or 0)) / sec / scale
    if math.abs(d) > 0.0005 then parts[#parts + 1] = string.format("%s %.3f%s", k, d, unit) end
  end
  return table.concat(parts, ", ")
end

local function report(p, label, now, before, samples)
  local sec = (now.tick - before.tick) / 60
  out("%s (%.0f s): power made %s", label, sec, fmt_rates(now.made, before.made, sec, 1e6, " MW"))
  out("%s: power used %s; load took %.3f MW", label, fmt_rates(now.used, before.used, sec, 1e6, " MW"),
    (now.absorbed - before.absorbed) / sec / 1e6)
  out("%s: crafts per s %s", label, fmt_rates(now.crafts, before.crafts, sec, 1, ""))
  out("%s: sources gave per s %s; sinks took per s %s", label, fmt_rates(now.given, before.given, sec, 1, ""),
    fmt_rates(now.taken, before.taken, sec, 1, ""))
  local items, parts = belt_items(p), {}
  for k, v in pairs(items) do parts[#parts + 1] = k .. " " .. v end
  table.sort(parts)
  out("%s: items on the box's belts now: %s", label, table.concat(parts, ", "))
  local ash, fuel, nb = 0, 0, 0
  for _, e in pairs(p.machines) do
    if e.valid and e.type == "boiler" then
      nb = nb + 1
      ash = ash + e.get_inventory(defines.inventory.burnt_result).get_item_count()
      fuel = fuel + e.get_inventory(defines.inventory.fuel).get_item_count()
    end
  end
  out("%s: %d Boilers hold %d fuel items and %d burnt results now", label, nb, fuel, ash)
  local full = {}
  for _, e in pairs(p.machines) do
    if e.valid and e.type == "boiler" then
      local n = e.get_inventory(defines.inventory.burnt_result).get_item_count()
      if n >= 50 then full[#full + 1] = string.format("%.1f,%.1f %d", e.position.x, e.position.y, n) end
    end
  end
  if #full > 0 then out("%s: Boilers holding 50 or more burnt results: %s", label, table.concat(full, ", ")) end
  local keys = {}
  for k in pairs(samples) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local s, total = {}, 0
    for _, c in pairs(samples[k]) do total = total + c end
    for st, c in pairs(samples[k]) do s[#s + 1] = string.format("%s %.0f%%", st, 100 * c / total) end
    table.sort(s)
    out("%s: status %s: %s", label, k, table.concat(s, ", "))
  end
end

local function fuel_name(e)
  local ok, cb = pcall(function() return e.burner.currently_burning end)
  if not ok or not cb then return nil end
  local n = cb.name
  if type(n) ~= "string" then n = n.name end
  return n
end

local function group_key(p, e)
  if e.type == "boiler" then
    local u = e.unit_number
    p.fuel[u] = p.fuel[u] or fuel_name(e)
    return string.format("%s at y %.1f on %s", e.name, e.position.y, p.fuel[u] or "-")
  end
  if e.type == "generator" then return e.name end
  if p.each[e.name] then return string.format("%s at %.1f,%.1f", e.name, e.position.x, e.position.y) end
  local r = e.type ~= "mining-drill" and e.get_recipe()
  return e.name .. " / " .. (r and r.name or "-")
end

script.on_event(defines.events.on_tick, function()
  local p = storage.p
  if not p then return end
  for _, s in ipairs(p.sources) do
    for line = 1, 2 do
      if s.e.get_transport_line(line).insert_at_back({ name = s.item, count = 1 }) then s.n = s.n + 1 end
    end
  end
  for _, s in ipairs(p.sinks) do
    for line = 1, s.e.get_max_transport_line_index() do
      local tl = s.e.get_transport_line(line)
      for _, c in pairs(tl.get_contents()) do p.taken[c.name] = (p.taken[c.name] or 0) + c.count end
      tl.clear()
    end
  end
  p.absorbed = p.absorbed + p.load.energy
  p.load.energy = 0
end)

script.on_nth_tick(60, function()
  local p = storage.p
  if not p or p.done then return end
  local t = (game.tick - p.start) / 60
  if t < WARM then return end
  if not p.before then
    p.before = snapshot(p)
    p.step_before = p.before
    p.samples, p.step_samples = {}, {}
    return
  end
  for _, e in pairs(p.machines) do
    if e.valid then
      local k = group_key(p, e)
      local s = STATUS[e.status] or "?"
      for _, g in ipairs({ p.samples, p.step_samples }) do
        g[k] = g[k] or {}
        g[k][s] = (g[k][s] or 0) + 1
      end
    end
  end
  p.seconds = (p.seconds or 0) + 1
  if p.seconds % STEP == 0 then
    local now = snapshot(p)
    report(p, string.format("step %d s", p.seconds), now, p.step_before, p.step_samples)
    p.step_before, p.step_samples = now, {}
  end
  if p.seconds >= MEASURE then
    p.done = true
    report(p, "total", snapshot(p), p.before, p.samples)
  end
end)
