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
-- machine group's statuses (Boilers by row and the fuel they burn; a Boiler's samples before it
-- first burns anything count under "on -", so such a group is not a Boiler that never burns).
-- Variant: "WARM,MEASURE,STEP" then ";key=value" fields, lists separated by "|":
--   box=x1:y1:x2:y2          the block
--   src=item@x:y|...         belt tiles kept full of item
--   sink=x:y|...             belt tiles emptied every tick
--   water=x:y|...            infinity pipes of Water
--   place=name@x:y[:dir[:item]]|... entities placed (dir north, east, south, west; default
--                            north; an inserter's direction is the side it picks up from;
--                            item: an inserter's whitelist filter; for an underground belt
--                            input or output, for a crafting machine its recipe)
--   load=x:y                 the energy interface (2x2; inside a pole's supply area)
--   each=name|...            machines of that name sampled one by one, not as a group (also
--                            boiler: each Boiler with the fuel it burns)
--   lanes=x:y|...            belt tiles whose two lanes are watched every tick: items that passed
--                            each lane per second (left and right, looking the way the belt runs;
--                            counted by the items' ids) and the mean items on each lane
--   prime=item:count         fuel put into every Boiler of the box once (a block that powers its
--                            own crushers cannot start itself)
--   isolate=1                the copper wires from the box's poles to poles outside it cut (a block
--                            the author built into the base's network, measured alone); a pole
--                            group of the box left on its own is joined to the largest by a wire
--   fill=fluid:amount@x:y|.. a Storage tank on that tile filled once; the reports show how fast
--                            it empties (the fuel a fluid-burning Boiler takes)
--   turn=x:y:dir|...         the entity on that tile turned to face dir (e.g. a Pipe to ground
--                            placed the wrong way round)
--   filter=x:y:item|...      the inserter on that tile filtered to item instead (whitelist)
--   stagger=seed:gap:name    the box's machines of that name stopped and emptied of work in
--                            progress, then started one by one in a random order, each 0 to gap s
--                            after the one before (seeded random): different start phases

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
local STATUS_DIR = {}
for k, v in pairs(defines.direction) do STATUS_DIR[v] = k end

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
    local ug = prototypes.entity[name] and prototypes.entity[name].type == "underground-belt"
    local e = surface.create_entity({ name = name, position = { num(x), num(y) }, force = f,
      direction = defines.direction[dir ~= "" and dir or "north"], type = ug and filter or nil })
    if e then
      placed[name] = (placed[name] or 0) + 1
      if filter ~= "" and e.type == "assembling-machine" then
        e.set_recipe(filter)
      elseif filter ~= "" and not ug then
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
  -- isolate=1 cuts the copper wires from the box's poles to poles outside it: a block built into
  -- the base's network then runs on its own power, as the block alone.
  if opt.isolate == "1" then
    local inside, cut = {}, 0
    local poles = surface.find_entities_filtered({ area = area, type = "electric-pole" })
    for _, p in pairs(poles) do inside[p.unit_number] = true end
    for _, p in pairs(poles) do
      local c = p.get_wire_connector(defines.wire_connector_id.pole_copper, false)
      if c then
        for _, w in pairs(c.connections) do
          if not inside[w.target.owner.unit_number] then
            c.disconnect_from(w.target, w.origin)
            cut = cut + 1
          end
        end
      end
    end
    out("isolated the box: %d copper wires to poles outside cut", cut)
    -- Pole groups of the box that reached the block only through outside poles are joined back to
    -- the largest group by one wire between their closest poles (in the base they share a network).
    local groups = {}
    for _, p in pairs(poles) do
      local id = p.electric_network_id
      groups[id] = groups[id] or {}
      table.insert(groups[id], p)
    end
    local main
    for id, g in pairs(groups) do if not main or #g > #groups[main] then main = id end end
    for id, g in pairs(groups) do
      if id ~= main then
        local best, d
        for _, a in pairs(g) do
          for _, b in pairs(groups[main]) do
            local dd = (a.position.x - b.position.x) ^ 2 + (a.position.y - b.position.y) ^ 2
            if not d or dd < d then best, d = { a, b }, dd end
          end
        end
        best[1].get_wire_connector(defines.wire_connector_id.pole_copper, true).connect_to(
          best[2].get_wire_connector(defines.wire_connector_id.pole_copper, true), false)
        out("joined %d poles at %.1f,%.1f to the block's network (wire to %.1f,%.1f, %.1f tiles)", #g,
          best[1].position.x, best[1].position.y, best[2].position.x, best[2].position.y, math.sqrt(d))
      end
    end
  end
  for _, s in ipairs(list(opt.turn)) do
    local x, y, dir = s:match("^([%-%.%d]+):([%-%.%d]+):(%a+)$")
    local e = surface.find_entities_filtered({ position = { num(x), num(y) } })[1]
    if e then e.direction = defines.direction[dir] end
    out("turned %s at %s:%s to %s", e and e.name or "nothing", x, y, e and STATUS_DIR[e.direction] or "-")
  end
  for _, s in ipairs(list(opt.filter)) do
    local x, y, item = s:match("^([%-%.%d]+):([%-%.%d]+):([%w%-_]+)$")
    local e = surface.find_entities_filtered({ position = { num(x), num(y) }, type = "inserter" })[1]
    if e then
      e.use_filters = true
      e.inserter_filter_mode = "whitelist"
      e.set_filter(1, item)
    end
    out("filter of the inserter at %s:%s: %s", x, y, e and item or "no inserter")
  end
  for n, c in pairs(placed) do out("placed %d %s", c, n) end
  if #missed > 0 then out("could not place: %s", table.concat(missed, " ")) end

  for _, w in ipairs(list(opt.water)) do
    local x, y = w:match("([%-%.%d]+):([%-%.%d]+)")
    local e = surface.create_entity({ name = "infinity-pipe", position = { num(x), num(y) }, force = f })
    if e then e.set_infinity_pipe_filter({ name = "water", percentage = 1, temperature = 15, mode = "at-least" }) end
    out("water at %s: %s", w, e and "ok" or "FAILED")
  end

  -- A Storage tank filled once with a fluid fuel: the reports show how fast it empties, which is
  -- the fuel a fluid-burning Boiler took.
  local tanks = {}
  for _, s in ipairs(list(opt.fill)) do
    local fluid, amount, x, y = s:match("^([%w%-_]+):(%d+)@([%-%.%d]+):([%-%.%d]+)$")
    local e = surface.find_entities_filtered({ position = { num(x), num(y) }, type = "storage-tank" })[1]
    local n = e and e.insert_fluid({ name = fluid, amount = num(amount) }) or 0
    out("filled the tank at %s:%s with %.0f %s", x, y, n, fluid)
    if e then tanks[#tanks + 1] = { e = e, fluid = fluid, at = x .. ":" .. y } end
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
      local inv = b.get_inventory(defines.inventory.fuel)
      if inv then nb = nb + inv.insert({ name = item, count = num(count) }) end
    end
    out("primed the Boilers with %d %s", nb, item)
  end

  -- stagger=seed:gap:name starts the box's machines of that name one by one: all stopped, their
  -- work in progress and output cleared (and the Boilers' Ash), then switched on in a random order,
  -- each a random 0 to gap seconds after the one before. Seeds give different start phases.
  local starts = {}
  if opt.stagger then
    local seed, gap, name = opt.stagger:match("^(%d+):([%d%.]+):([%w%-_]+)$")
    -- Seeds 1, 2 and 3 gave the same sequence (small seeds end up as one), so they are spread out.
    local rng = game.create_random_generator(341 + num(seed) * 7919)
    for _, b in pairs(surface.find_entities_filtered({ area = area, type = "boiler" })) do
      local inv = b.get_inventory(defines.inventory.burnt_result)
      if inv then inv.clear() end
    end
    local machines = surface.find_entities_filtered({ area = area, name = name })
    for i = #machines, 2, -1 do
      local j = rng(i)
      machines[i], machines[j] = machines[j], machines[i]
    end
    local t = 0
    for _, m in ipairs(machines) do
      m.disabled_by_script = true
      m.crafting_progress = 0
      local inv = m.get_output_inventory()
      if inv then inv.clear() end
      t = t + math.floor(rng() * num(gap) * 60)
      starts[#starts + 1] = { e = m, tick = game.tick + t }
    end
    out("stagger seed %s: %d %s started over %.1f s", seed, #starts, name, t / 60)
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
  -- A network without the load is cut off from the block's engines: name its poles and machines.
  for id, c in pairs(nets) do
    if id ~= load.electric_network_id then
      local at, what = {}, {}
      for _, p in pairs(poles) do
        if p.electric_network_id == id then at[#at + 1] = string.format("%.1f,%.1f", p.position.x, p.position.y) end
      end
      for _, e in pairs(surface.find_entities_filtered({ area = area })) do
        if e.type ~= "electric-pole" and e.electric_network_id == id then what[e.name] = (what[e.name] or 0) + 1 end
      end
      local w = {}
      for k, v in pairs(what) do w[#w + 1] = v .. " " .. k end
      out("network %d (no load): poles %s; powers %s", id, table.concat(at, " "), table.concat(w, ", "))
    end
  end

  storage.p = {
    surface = surface, area = area, sources = sources, sinks = sinks, load = load, absorbed = 0, tanks = tanks,
    pole = poles[1], taken = {}, start = game.tick,
    machines = surface.find_entities_filtered({ area = area,
      type = { "assembling-machine", "furnace", "boiler", "generator", "mining-drill" } }),
    belts = surface.find_entities_filtered({ area = area, type = BELTS }),
    fuel = {}, each = {}, starts = starts, next_start = 1,
  }
  for _, n in ipairs(list(opt.each)) do storage.p.each[n] = true end
  storage.p.lanes = {}
  for _, l in ipairs(list(opt.lanes)) do
    local x, y = l:match("([%-%.%d]+):([%-%.%d]+)")
    local e = belt_at(surface, num(x), num(y))
    if e then storage.p.lanes[#storage.p.lanes + 1] = { e = e, at = l, n = { 0, 0 }, t = 0, sn = { 0, 0 }, st = 0,
      f = { 0, 0 }, sf = { 0, 0 }, prev = { {}, {} } }
    else out("no belt for the lane sample %s", l) end
  end
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
  local s = { made = {}, used = {}, crafts = {}, absorbed = p.absorbed, given = {}, taken = {}, tick = game.tick,
    tank = {} }
  for _, t in ipairs(p.tanks) do
    if t.e.valid then s.tank[t.fluid .. " at " .. t.at] = t.e.get_fluid_count(t.fluid) end
  end
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
  if next(now.tank) then
    local left = {}
    for k, v in pairs(now.tank) do left[#left + 1] = string.format("%s %.0f", k, v) end
    out("%s: filled tanks emptied per s %s; left %s", label, fmt_rates(before.tank, now.tank, sec, 1, ""),
      table.concat(left, ", "))
  end
  local items, parts = belt_items(p), {}
  for k, v in pairs(items) do parts[#parts + 1] = k .. " " .. v end
  table.sort(parts)
  out("%s: items on the box's belts now: %s", label, table.concat(parts, ", "))
  -- A fluid-burning Boiler has no fuel or burnt result inventory.
  local function count(e, inv)
    local i = e.get_inventory(inv)
    return i and i.get_item_count() or 0
  end
  local ash, fuel, nb = 0, 0, 0
  for _, e in pairs(p.machines) do
    if e.valid and e.type == "boiler" then
      nb = nb + 1
      ash = ash + count(e, defines.inventory.burnt_result)
      fuel = fuel + count(e, defines.inventory.fuel)
    end
  end
  out("%s: %d Boilers hold %d fuel items and %d burnt results now", label, nb, fuel, ash)
  local full = {}
  for _, e in pairs(p.machines) do
    if e.valid and e.type == "boiler" then
      local n = count(e, defines.inventory.burnt_result)
      if n >= 50 then full[#full + 1] = string.format("%.1f,%.1f %d", e.position.x, e.position.y, n) end
    end
  end
  if #full > 0 then out("%s: Boilers holding 50 or more burnt results: %s", label, table.concat(full, ", ")) end
  -- The three Boilers holding the most burnt results, however few: a slow build-up shows early.
  local top = {}
  for _, e in pairs(p.machines) do
    if e.valid and e.type == "boiler" then top[#top + 1] = { e = e, n = count(e, defines.inventory.burnt_result) } end
  end
  table.sort(top, function(a, b) return a.n > b.n end)
  local most = {}
  for i = 1, math.min(3, #top) do
    most[i] = string.format("%.1f,%.1f %d", top[i].e.position.x, top[i].e.position.y, top[i].n)
  end
  if #most > 0 then out("%s: most burnt results: %s", label, table.concat(most, ", ")) end
  for _, l in ipairs(p.lanes) do
    local n, t, f = l.sn, l.st, l.sf
    if label == "total" then n, t, f = l.n, l.t, l.f end
    if t > 0 then
      out("%s: lanes at %s (%s %s): left %.3f/s (%.2f items), right %.3f/s (%.2f items)", label, l.at, l.e.name,
        STATUS_DIR[l.e.direction] or "-", f[1] / sec, n[1] / t, f[2] / sec, n[2] / t)
    end
    l.sn, l.st, l.sf = { 0, 0 }, 0, { 0, 0 }
  end
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
    if p.each[e.name] then
      return string.format("%s at %.1f,%.1f on %s", e.name, e.position.x, e.position.y, p.fuel[u] or "-")
    end
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
  while p.next_start <= #p.starts and p.starts[p.next_start].tick <= game.tick do
    local s = p.starts[p.next_start]
    if s.e.valid then s.e.disabled_by_script = false end
    p.next_start = p.next_start + 1
  end
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
  if p.before and not p.done then
    for _, l in ipairs(p.lanes) do
      for i = 1, 2 do
        local now, new = {}, 0
        for _, it in pairs(l.e.get_transport_line(i).get_detailed_contents()) do
          now[it.unique_id] = true
          if not l.prev[i][it.unique_id] then new = new + 1 end
        end
        l.prev[i] = now
        l.f[i], l.sf[i] = l.f[i] + new, l.sf[i] + new
      end
    end
  end
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
  for _, l in ipairs(p.lanes) do
    for i = 1, 2 do
      local c = l.e.get_transport_line(i).get_item_count()
      l.n[i], l.sn[i] = l.n[i] + c, l.sn[i] + c
    end
    l.t, l.st = l.t + 1, l.st + 1
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
