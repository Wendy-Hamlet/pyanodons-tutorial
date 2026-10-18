-- Measures a save as it stands, over a longer window than the inspector's one minute
-- (tools/save-probe.ps1 runs it in a copy of the save; nothing in the base is changed).
-- After a warm-up it takes the force's production statistics, then samples the status of every
-- crafting machine and drill once a second, grouped by name and recipe (drills: by mined
-- resource; Boilers and Steam engines: by the row they stand in), and at the end prints what the
-- whole base made and used per second, and each electric network's mean power by generator and
-- consumer kind.
-- Variant: "WARM,MEASURE" in seconds (default "60,600"), optionally ",STEP,name;name;..." for a
-- timeline: every STEP seconds it also prints how much of each named item or fluid was made and
-- used per second in that step, and every machine group whose most frequent status changed; a
-- name "@x:y" instead is the entity with fluid boxes on that tile (a machine, a tank, a pond):
-- its status and the fluid in each of its boxes.
-- A last field ",+name@x:y;..." places those entities when the save loads: a what-if (say, the
-- pole that was taken out), the only change the probe then makes to the base. "name@x:y:south"
-- places it facing that way (north, east, south, west; default north).

local variant = require("variant")
local PLACE
variant, PLACE = variant:match("^([^+]*),?%+?(.*)$")
local WARM, MEASURE, STEP, WATCH = variant:match("^(%d+),(%d+),?(%d*),?(.*)$")
WARM, MEASURE, STEP = tonumber(WARM) or 60, tonumber(MEASURE) or 600, tonumber(STEP)
local watch = {}
for name in (WATCH or ""):gmatch("[^;,]+") do watch[#watch + 1] = name end

local function out(fmt, ...) log("CF-RATE " .. string.format(fmt, ...)) end
local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end

local function flow(stats)
  return { produced = stats.input_counts, consumed = stats.output_counts }
end

local function snapshot(surface)
  local force = game.forces.player
  return {
    items = flow(force.get_item_production_statistics(surface)),
    fluids = flow(force.get_fluid_production_statistics(surface)),
  }
end

-- Electric networks by id, with one pole of each (its statistics are the whole network's).
local function networks(surface)
  local by = {}
  for _, p in pairs(surface.find_entities_filtered({ type = "electric-pole" })) do
    local id = p.electric_network_id
    if id then
      by[id] = by[id] or { pole = p, poles = 0 }
      by[id].poles = by[id].poles + 1
    end
  end
  return by
end

-- Energy (J) given by each generator kind and taken by each consumer kind so far: on an electric
-- network output_counts are what generators gave and input_counts what consumers took.
local function energy(net)
  local st = net.pole.electric_network_statistics
  local e = { made = {}, used = {} }
  for k, v in pairs(st.output_counts) do e.made[k] = v end
  for k, v in pairs(st.input_counts) do e.used[k] = v end
  return e
end

local function group_key(e)
  -- Boilers and Steam engines have no recipe: grouped by the row they stand in.
  if e.type == "boiler" or e.type == "generator" then
    return string.format("%s at y %.1f", e.name, e.position.y)
  end
  if e.type == "mining-drill" then
    local t = e.mining_target
    return e.name .. " on " .. (t and t.name or "-")
  end
  local r = e.get_recipe()
  local name = r and r.name
  if not name and e.type == "furnace" and e.previous_recipe then
    name = e.previous_recipe.name
    if type(name) ~= "string" then name = name.name end
  end
  return e.name .. " / " .. (name or "-")
end

script.on_init(function()
  for name, x, y, dir in (PLACE or ""):gmatch("([%w%-_]+)@([%-%.%d]+):([%-%.%d]+):?(%a*)") do
    local e = game.surfaces.nauvis.create_entity({ name = name, position = { tonumber(x), tonumber(y) },
      direction = defines.direction[dir ~= "" and dir or "north"], force = "player" })
    out("placed %s at %s,%s %s: %s", name, x, y, dir ~= "" and dir or "north", e and "ok" or "FAILED")
  end
  storage.start = game.tick
  out("loaded at tick %d; warm %d s, measure %d s", game.tick, WARM, MEASURE)
end)

-- Prints one step of the timeline (t: seconds measured): the watched rates, and the groups whose
-- usual status changed.
local function step(now, t)
  local parts = {}
  for _, name in ipairs(watch) do
    local x, y = name:match("^@([%-%.%d]+):([%-%.%d]+)$")
    if x then
      local e
      for _, c in pairs(game.surfaces.nauvis.find_entities_filtered({ position = { tonumber(x), tonumber(y) } })) do
        local ok, n = pcall(function() return c.fluids_count end)
        if ok and n > 0 and c.type ~= "pipe" and c.type ~= "pipe-to-ground" then e = c end
      end
      if e then
        local boxes = {}
        for i = 1, e.fluids_count do
          local f = e.get_fluid(i)
          boxes[#boxes + 1] = f and string.format("%s %.0f", f.name, f.amount) or "-"
        end
        local ok, status = pcall(function() return e.status end)
        out("step %d s: %s at %s,%s: %s; fluid boxes: %s", t, e.name, x, y, ok and STATUS[status] or "-", table.concat(boxes, " | "))
      end
    end
  end
  for _, name in ipairs(watch) do
    if name:sub(1, 1) ~= "@" then
      local p, c = 0, 0
      for _, kind in ipairs({ "items", "fluids" }) do
        p = p + (now[kind].produced[name] or 0) - (storage.step_before[kind].produced[name] or 0)
        c = c + (now[kind].consumed[name] or 0) - (storage.step_before[kind].consumed[name] or 0)
      end
      parts[#parts + 1] = string.format("%s %.3f/%.3f", name, p / STEP, c / STEP)
    end
  end
  out("step %d s: made/used per s: %s", t, table.concat(parts, ", "))
  -- Power of the networks with more than 50 poles in this step (MW).
  for id, net in pairs(storage.nets or {}) do
    if net.pole.valid and net.poles > 50 then
      local e, before = energy(net), storage.power_step[id]
      local made, used = 0, 0
      for name, j in pairs(e.made) do made = made + j - (before.made[name] or 0) end
      for name, j in pairs(e.used) do used = used + j - (before.used[name] or 0) end
      out("step %d s: power network %d made %.1f MW, used %.1f MW", t, id, made / STEP / 1e6, used / STEP / 1e6)
      storage.power_step[id] = e
    end
  end
  storage.usual = storage.usual or {}
  for k, g in pairs(storage.step_samples) do
    local best, n, total = nil, 0, 0
    for s, c in pairs(g) do
      total = total + c
      if c > n then best, n = s, c end
    end
    if storage.usual[k] ~= best then
      out("step %d s: %s now %s (%.0f%%; was %s)", t, k, best, 100 * n / total, storage.usual[k] or "-")
      storage.usual[k] = best
    end
  end
  storage.step_before = now
  storage.step_samples = {}
end

script.on_nth_tick(60, function()
  local surface = game.surfaces.nauvis
  local t = game.tick - storage.start
  if t < WARM * 60 then return end
  if not storage.before then
    storage.before = snapshot(surface)
    storage.step_before = storage.before
    storage.samples = {}
    storage.step_samples = {}
    storage.machines = surface.find_entities_filtered({ force = "player",
      type = { "assembling-machine", "furnace", "mining-drill", "boiler", "generator" } })
    storage.nets = networks(surface)
    storage.power_before = {}
    for id, net in pairs(storage.nets) do storage.power_before[id] = energy(net) end
    storage.power_step = {}
    for id, e in pairs(storage.power_before) do storage.power_step[id] = e end
    return
  end
  if storage.done then return end
  for _, e in pairs(storage.machines) do
    if e.valid then
      local k = group_key(e)
      local g = storage.samples[k] or {}
      storage.samples[k] = g
      local s = STATUS[e.status] or "?"
      g[s] = (g[s] or 0) + 1
      if STEP then
        local h = storage.step_samples[k] or {}
        storage.step_samples[k] = h
        h[s] = (h[s] or 0) + 1
      end
    end
  end
  -- Seconds measured so far (the load tick need not fall on a whole second).
  storage.seconds = (storage.seconds or 0) + 1
  if STEP and storage.seconds % STEP == 0 then step(snapshot(surface), storage.seconds) end
  if t < (WARM + MEASURE) * 60 then return end
  storage.done = true
  local now = snapshot(surface)
  for _, kind in ipairs({ "items", "fluids" }) do
    for _, dir in ipairs({ "produced", "consumed" }) do
      local list = {}
      for name, count in pairs(now[kind][dir]) do
        local d = (count - (storage.before[kind][dir][name] or 0)) / MEASURE
        if d > 0.004 then list[#list + 1] = { name, d } end
      end
      table.sort(list, function(a, b) return a[2] > b[2] end)
      local parts = {}
      for _, p in ipairs(list) do parts[#parts + 1] = string.format("%s %.3f", p[1], p[2]) end
      out("%s %s per s: %s", kind, dir, table.concat(parts, ", "))
    end
  end
  -- Mean power of every network with more than one pole, by generator and consumer kind (MW).
  for id, net in pairs(storage.nets) do
    if net.pole.valid and net.poles > 1 then
      local now_e, before = energy(net), storage.power_before[id]
      for _, side in ipairs({ "made", "used" }) do
        local list, total = {}, 0
        for name, j in pairs(now_e[side]) do
          local mw = (j - (before[side][name] or 0)) / MEASURE / 1e6
          total = total + mw
          if mw > 0.05 then list[#list + 1] = { name, mw } end
        end
        table.sort(list, function(a, b) return a[2] > b[2] end)
        local parts = {}
        for _, p in ipairs(list) do parts[#parts + 1] = string.format("%s %.2f", p[1], p[2]) end
        out("power network %d (%d poles) %s %.1f MW: %s", id, net.poles, side, total, table.concat(parts, ", "))
      end
    end
  end
  local keys = {}
  for k in pairs(storage.samples) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local parts, total = {}, 0
    for _, n in pairs(storage.samples[k]) do total = total + n end
    for s, n in pairs(storage.samples[k]) do parts[#parts + 1] = string.format("%s %.0f%%", s, 100 * n / total) end
    table.sort(parts)
    out("status %s (%d samples): %s", k, total, table.concat(parts, ", "))
  end
end)
