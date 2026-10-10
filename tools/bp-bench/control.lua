-- Blueprint bench: builds one blueprint from blueprints/ on an empty lab surface and measures
-- whether it reaches full speed when nothing outside it is the limit: an energy interface on every
-- electric network of the blueprint (unlimited power), a water tile in front of every Offshore
-- pump, script sources that keep both lanes of each input belt full, script sinks that empty each
-- output belt, and labs that research without end. After a warm-up it compares every machine's
-- finished crafts with what its recipe allows at its speed (modules included), samples statuses
-- and which ingredient a waiting machine lacks, and counts what the sources gave and the sinks
-- took. Results are CF-BENCH log lines.
-- Run by tools/bp-bench.ps1, which writes bench-data.lua: the bench (benches/<name>.json), the
-- variant and the blueprint string.

local data = require("bench-data")
local spec = helpers.json_to_table(data.spec)
local variant = data.variant ~= "" and spec.variants and spec.variants[data.variant]
if data.variant ~= "" and not variant then error("unknown variant " .. data.variant) end
local SAMPLE = 60

local function out(fmt, ...) log("CF-BENCH " .. string.format(fmt, ...)) end
local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end
local AHEAD = { [defines.direction.north] = { 0, -1 }, [defines.direction.east] = { 1, 0 },
  [defines.direction.south] = { 0, 1 }, [defines.direction.west] = { -1, 0 } }
local CRAFTERS = { "assembling-machine", "furnace" }

local function concat(a, b)
  local r = {}
  for _, v in ipairs(a or {}) do r[#r + 1] = v end
  for _, v in ipairs(b or {}) do r[#r + 1] = v end
  return r
end
local function list(t, fmt)
  local parts = {}
  for k, v in pairs(t) do parts[#parts + 1] = { k, v } end
  table.sort(parts, function(a, b) return a[2] > b[2] end)
  for i, p in ipairs(parts) do parts[i] = string.format(fmt or "%s %s", p[1], p[2]) end
  return table.concat(parts, ", ")
end

-- The belt (or underground) whose tile is (x, y) in blueprint coordinates.
local function belt_at(surface, x, y, dx, dy)
  local px, py = x + 0.5 + dx, y + 0.5 + dy
  return surface.find_entities_filtered({ area = { { px - 0.1, py - 0.1 }, { px + 0.1, py + 0.1 } },
    type = { "transport-belt", "underground-belt", "splitter" } })[1]
end

script.on_init(function()
  local f = game.forces.player
  for _, name in ipairs(spec.research or {}) do
    local t = f.technologies[name]
    if t then t.researched = true else out("unknown technology %s", name) end
  end

  local inv = game.create_inventory(1)
  local stack = inv[1]
  local result = stack.import_stack(data.blueprint)
  if result ~= 0 then out("blueprint import returned %d (0 = clean)", result) end
  local entities = stack.get_blueprint_entities()
  local x1, y1, x2, y2 = math.huge, math.huge, -math.huge, -math.huge
  for _, e in ipairs(entities) do
    -- Recipes the blueprint sets, also ones a choice in the author's game unlocked (TURD).
    if e.recipe and f.recipes[e.recipe] then f.recipes[e.recipe].enabled = true end
    x1, y1 = math.min(x1, e.position.x), math.min(y1, e.position.y)
    x2, y2 = math.max(x2, e.position.x), math.max(y2, e.position.y)
  end

  local surface = game.create_surface("bench")
  surface.generate_with_lab_tiles = true
  surface.always_day = true
  local cx, cy = math.floor((x1 + x2) / 2), math.floor((y1 + y2) / 2)
  surface.request_to_generate_chunks({ cx, cy }, math.ceil(math.max(x2 - x1, y2 - y1) / 64) + 2)
  surface.force_generate_chunk_requests()

  local function build()
    return stack.build_blueprint({ surface = surface, force = f, position = { cx, cy },
      build_mode = defines.build_mode.forced })
  end
  -- Where the blueprint lands: the top-left entity of one name, in the blueprint and as a ghost.
  local name = entities[1].name
  local function first(list, pos)
    local best
    for _, v in pairs(list) do
      local p = pos(v)
      if p and (not best or p.y < best.y or (p.y == best.y and p.x < best.x)) then best = p end
    end
    return best
  end
  local ghosts = build()
  local a = first(entities, function(e) return e.name == name and e.position or nil end)
  local b = first(ghosts, function(g) return g.valid and g.name == "entity-ghost" and g.ghost_name == name and g.position or nil end)
  local dx, dy = b.x - a.x, b.y - a.y
  for _, g in pairs(ghosts) do if g.valid then g.destroy() end end

  -- Offshore pumps draw from the tile ahead of them (fluid_source_offset {0, -1} facing north).
  local water, pumps = {}, {}
  for _, e in ipairs(entities) do
    if prototypes.entity[e.name].type == "offshore-pump" then
      local d = e.direction or defines.direction.north
      local px, py = e.position.x + dx, e.position.y + dy
      water[#water + 1] = { name = "water", position = { math.floor(px + AHEAD[d][1]), math.floor(py + AHEAD[d][2]) } }
      pumps[#pumps + 1] = { name = e.name, position = { px, py }, direction = d }
    end
  end
  if #water > 0 then surface.set_tiles(water, false) end

  build()
  local built, failed = 0, {}
  for _, g in pairs(surface.find_entities_filtered({ type = "entity-ghost" })) do
    local ghost_name = g.ghost_name
    local _, e = g.revive()
    if e then built = built + 1 else failed[ghost_name] = (failed[ghost_name] or 0) + 1 end
  end
  for _, p in ipairs(pumps) do
    if #surface.find_entities_filtered({ name = p.name, position = p.position }) == 0 then
      if surface.create_entity({ name = p.name, position = p.position, direction = p.direction, force = f }) then
        built = built + 1
        failed[p.name] = (failed[p.name] or 1) - 1
      end
    end
  end
  -- Modules and other item requests of the blueprint, put straight into their slots.
  local requested = {}
  for _, p in pairs(surface.find_entities_filtered({ name = "item-request-proxy" })) do
    local target = p.proxy_target
    for _, plan in pairs(p.insert_plan) do
      for _, at in pairs(plan.items.in_inventory or {}) do
        local slots = target.get_inventory(at.inventory)
        if slots then
          slots[at.stack + 1].set_stack({ name = plan.id.name, quality = plan.id.quality, count = at.count or 1 })
          requested[plan.id.name] = (requested[plan.id.name] or 0) + (at.count or 1)
        end
      end
    end
    p.destroy()
  end

  -- Unlimited power: a substation wired to one pole of each network, and an energy interface.
  local networks, n_networks = {}, 0
  for _, pole in pairs(surface.find_entities_filtered({ type = "electric-pole" })) do
    local id = pole.electric_network_id
    if id and not networks[id] then networks[id] = pole; n_networks = n_networks + 1 end
  end
  for _, pole in pairs(networks) do
    local sub = surface.create_entity({ name = "substation", force = f,
      position = surface.find_non_colliding_position("substation", pole.position, 6, 0.5) })
    sub.get_wire_connector(defines.wire_connector_id.pole_copper, true)
      .connect_to(pole.get_wire_connector(defines.wire_connector_id.pole_copper, true), false)
    local eei = surface.create_entity({ name = "electric-energy-interface", force = f,
      position = surface.find_non_colliding_position("electric-energy-interface", sub.position, 7, 0.5) })
    eei.electric_buffer_size = 1e12
    eei.power_production = 1e10
  end

  local sources, sinks = {}, {}
  for _, s in ipairs(concat(spec.sources, variant and variant.sources)) do
    local e = belt_at(surface, s.x, s.y, dx, dy)
    if e then sources[#sources + 1] = { e = e, item = s.item, n = 0 }
    else out("no belt for the source at (%d, %d)", s.x, s.y) end
  end
  for _, s in ipairs(concat(spec.sinks, variant and variant.sinks)) do
    local e = belt_at(surface, s.x, s.y, dx, dy)
    if e then sinks[#sinks + 1] = { e = e, got = {} }
    else out("no belt for the sink at (%d, %d)", s.x, s.y) end
  end
  for _, p in ipairs(spec.prime or {}) do
    local px, py = p.x + dx, p.y + dy
    for _, e in pairs(surface.find_entities_filtered({ area = { { px - 0.1, py - 0.1 }, { px + 0.1, py + 0.1 } } })) do
      if e.type ~= "transport-belt" and e.type ~= "underground-belt" then
        out("primed %s with %d %s", e.name, e.insert({ name = p.item, count = p.count }), p.item)
        break
      end
    end
  end
  if spec.lab_research and not f.add_research(spec.lab_research) then out("could not research %s", spec.lab_research) end

  local machines, labs = {}, {}
  for _, e in pairs(surface.find_entities_filtered({ type = CRAFTERS })) do
    local r = e.get_recipe()
    if r then machines[#machines + 1] = { e = e, key = e.name .. " / " .. r.name, recipe = r } end
  end
  for _, e in pairs(surface.find_entities_filtered({ type = "lab" })) do labs[#labs + 1] = e end
  -- Single entities to watch (say an inserter suspected of being the limit): status samples.
  local watch = {}
  for _, w in ipairs(concat(spec.watch, variant and variant.watch)) do
    local px, py = w.x + dx, w.y + dy
    local e = surface.find_entities_filtered({ area = { { px - 0.1, py - 0.1 }, { px + 0.1, py + 0.1 } } })[1]
    if e then watch[#watch + 1] = { e = e, label = string.format("%s at (%g, %g)", e.name, w.x, w.y), status = {} }
    else out("nothing to watch at (%g, %g)", w.x, w.y) end
  end

  out("bench %s%s: built %d of %d entities (failed: %s), offset (%g, %g), %d power network(s), requests filled: %s",
    data.name, data.variant ~= "" and (" / " .. data.variant) or "", built, #entities, list(failed), dx, dy,
    n_networks, list(requested))
  storage.bench = { surface = surface, sources = sources, sinks = sinks, machines = machines, labs = labs, watch = watch,
    warm = spec.warm * 60, measure = spec.measure * 60, window = (spec.window or spec.measure) * 60 }
end)

local function stats(b)
  local f = game.forces.player
  local items = f.get_item_production_statistics(b.surface)
  local fluids = f.get_fluid_production_statistics(b.surface)
  return { made = items.input_counts, used = items.output_counts, fmade = fluids.input_counts, fused = fluids.output_counts }
end
local function diff(now, before)
  local r = {}
  for k, v in pairs(now) do if v - (before[k] or 0) > 0 then r[k] = v - (before[k] or 0) end end
  return r
end
local function rates(t, seconds)
  local r = {}
  for k, v in pairs(t) do r[k] = math.floor(v / seconds * 1000 + 0.5) / 1000 end
  return r
end

-- Window and final report: crafts against the recipe's full speed, per machine group.
local function report(b, seconds, final)
  local groups, order = {}, {}
  for _, m in ipairs(b.machines) do
    local g = groups[m.key]
    if not g then
      g = { n = 0, done = 0, full = 0, status = {}, short = {}, recipe = m.recipe }
      groups[m.key] = g; order[#order + 1] = m.key
    end
    g.n = g.n + 1
    g.done = g.done + (m.e.products_finished - m.mark)
    g.full = g.full + seconds * m.e.crafting_speed / m.recipe.energy
    for k, v in pairs(m.status) do g.status[k] = (g.status[k] or 0) + v end
    for k, v in pairs(m.short) do g.short[k] = (g.short[k] or 0) + v end
  end
  table.sort(order)
  for _, key in ipairs(order) do
    local g = groups[key]
    local made = {}
    for _, p in ipairs(g.recipe.products) do
      -- 2.1 chances: an own roll (independent_probability) times a share of one roll for all
      -- products (shared_probability {min, max}).
      local amount = p.amount or ((p.amount_min + p.amount_max) / 2)
      local chance = (p.independent_probability or 1)
        * (p.shared_probability and (p.shared_probability.max - p.shared_probability.min) or 1)
      made[#made + 1] = string.format("%.3f %s/s", g.done * amount * chance / seconds, p.name)
    end
    if final then
      out("  %s ×%d: %d of %.1f crafts = %.0f %%, makes %s; status samples: %s%s", key, g.n, g.done, g.full,
        100 * g.done / g.full, table.concat(made, ", "), list(g.status),
        next(g.short) and ("; short of: " .. list(g.short)) or "")
    else
      out("  %s ×%d: %.0f %%", key, g.n, 100 * g.done / g.full)
    end
  end
  local given, taken = {}, {}
  for _, s in ipairs(b.sources) do given[s.item] = (given[s.item] or 0) + s.n end
  for _, s in ipairs(b.sinks) do for k, v in pairs(s.got) do taken[k] = (taken[k] or 0) + v end end
  out("  sources gave (per s): %s; sinks took (per s): %s", list(rates(given, seconds)), list(rates(taken, seconds)))
  if #b.labs > 0 then
    local st = {}
    for k, v in pairs(b.lab_status) do st[k] = v end
    out("  labs ×%d: status samples %s", #b.labs, list(st))
  end
  if final then
    local now = stats(b)
    out("  items made (per s): %s", list(rates(diff(now.made, b.stats.made), seconds)))
    out("  items used (per s): %s", list(rates(diff(now.used, b.stats.used), seconds)))
    out("  fluids made (per s): %s", list(rates(diff(now.fmade, b.stats.fmade), seconds)))
    out("  fluids used (per s): %s", list(rates(diff(now.fused, b.stats.fused), seconds)))
  end
end

local function mark(b)
  for _, m in ipairs(b.machines) do m.mark, m.status, m.short = m.e.products_finished, {}, {} end
  for _, s in ipairs(b.sources) do s.n = 0 end
  for _, s in ipairs(b.sinks) do s.got = {} end
  b.lab_status = {}
end

script.on_event(defines.events.on_tick, function()
  local b = storage.bench
  if not b then return end
  for _, s in ipairs(b.sources) do
    for line = 1, 2 do
      if s.e.get_transport_line(line).insert_at_back({ name = s.item, count = 1 }) then s.n = s.n + 1 end
    end
  end
  for _, s in ipairs(b.sinks) do
    for line = 1, s.e.get_max_transport_line_index() do
      local tl = s.e.get_transport_line(line)
      if #tl > 0 then
        for _, c in pairs(tl.get_contents()) do s.got[c.name] = (s.got[c.name] or 0) + c.count end
        tl.clear()
      end
    end
  end
  local t = game.tick
  -- Labs research the same technology for ever.
  if t % 600 == 0 and game.forces.player.research_progress > 0.5 then game.forces.player.research_progress = 0.1 end
  if t == b.warm then
    mark(b)
    b.stats, b.window_start, b.measure_start = stats(b), t, t
    b.total = { machines = {}, sources = {}, sinks = {}, labs = {} }
    return
  end
  if t < b.warm or b.done then return end
  if t % SAMPLE == 0 then
    for _, m in ipairs(b.machines) do
      local s = STATUS[m.e.status] or "?"
      m.status[s] = (m.status[s] or 0) + 1
      if s == "item_ingredient_shortage" or s == "fluid_ingredient_shortage" then
        local inv = m.e.get_inventory(defines.inventory.crafter_input)
        for _, ing in ipairs(m.recipe.ingredients) do
          local have = 0
          if ing.type == "item" then have = inv.get_item_count(ing.name)
          else have = m.e.get_fluid_count(ing.name) end
          if have < ing.amount then m.short[ing.name] = (m.short[ing.name] or 0) + 1 end
        end
      end
    end
    for _, l in ipairs(b.labs) do
      local s = STATUS[l.status] or "?"
      b.lab_status[s] = (b.lab_status[s] or 0) + 1
    end
    for _, w in ipairs(b.watch) do
      local s = STATUS[w.e.status] or "?"
      w.status[s] = (w.status[s] or 0) + 1
    end
  end
  if (t - b.window_start) % b.window == 0 then
    local from = (b.window_start - b.measure_start) / 60
    out("window %d–%d s:", from + spec.warm, (t - b.measure_start) / 60 + spec.warm)
    report(b, b.window / 60, false)
    -- Keep the window's counts for the final report, then start the next window.
    for i, m in ipairs(b.machines) do
      local tm = b.total.machines[i] or { done = 0, status = {}, short = {} }
      tm.done = tm.done + (m.e.products_finished - m.mark)
      for k, v in pairs(m.status) do tm.status[k] = (tm.status[k] or 0) + v end
      for k, v in pairs(m.short) do tm.short[k] = (tm.short[k] or 0) + v end
      b.total.machines[i] = tm
    end
    for i, s in ipairs(b.sources) do b.total.sources[i] = (b.total.sources[i] or 0) + s.n end
    for i, s in ipairs(b.sinks) do
      local ts = b.total.sinks[i] or {}
      for k, v in pairs(s.got) do ts[k] = (ts[k] or 0) + v end
      b.total.sinks[i] = ts
    end
    for k, v in pairs(b.lab_status) do b.total.labs[k] = (b.total.labs[k] or 0) + v end
    mark(b)
    b.window_start = t
    if t - b.measure_start >= b.measure then
      for i, m in ipairs(b.machines) do
        local tm = b.total.machines[i]
        m.mark, m.status, m.short = m.e.products_finished - tm.done, tm.status, tm.short
      end
      for i, s in ipairs(b.sources) do s.n = b.total.sources[i] end
      for i, s in ipairs(b.sinks) do s.got = b.total.sinks[i] end
      b.lab_status = b.total.labs
      out("total over %d s after %d s warm-up:", b.measure / 60, spec.warm)
      report(b, b.measure / 60, true)
      for _, w in ipairs(b.watch) do out("  watched %s: status samples %s", w.label, list(w.status)) end
      b.done = true
    end
  end
end)
