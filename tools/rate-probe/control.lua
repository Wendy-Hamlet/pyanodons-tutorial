-- Measures a save as it stands, over a longer window than the inspector's one minute
-- (tools/save-probe.ps1 runs it in a copy of the save; nothing in the base is changed).
-- After a warm-up it takes the force's production statistics, then samples the status of every
-- crafting machine and drill once a second, grouped by name and recipe (drills: by mined
-- resource; Boilers and Steam engines: by the row they stand in), and at the end prints what the
-- whole base made and used per second, and each electric network's mean power by generator and
-- consumer kind. Py's Gas vents and Sinkholes void a fluid in batches of 20,000 (half a second
-- each) and read no_ingredients while the next batch fills; they are reported as filling_batch,
-- and the end prints what flowed into each of them per second (0 means nothing reaches it).
-- Variant: "WARM,MEASURE" in seconds (default "60,600"), optionally ",STEP,name;name;..." for a
-- timeline: every STEP seconds it also prints how much of each named item or fluid was made and
-- used per second in that step, and every machine group whose most frequent status changed; a
-- name "@x:y" instead is the entity with fluid boxes on that tile (a machine, a tank, a pond):
-- its status, the fluid in each of its boxes and, for a crafting machine, its input slots.
-- A last field ",+name@x:y;..." places those entities when the save loads: a what-if (say, the
-- pole that was taken out), the only change the probe then makes to the base. "name@x:y:south"
-- places it facing that way (north, east, south, west; default north; an inserter faces the side
-- it picks up from), "name@x:y:dir:item" also gives an inserter that whitelist filter or a
-- crafting machine that recipe; "infinity-pipe@x:y::steam*250" is an endless source of that
-- fluid at that temperature (its output counts in no statistics: made minus used shows it; behind
-- an Underflow valve it only tops a line up, a stand-in for a block not built yet). Some names
-- there are not
-- entities: "sink@x:y" empties the belt on that tile every tick, "empty@x:y" the chest on that
-- tile every second (a user taking all the block makes, for a block standing full); what they
-- took is printed per second at the end. "off@x:y" stops the machine (or inserter) on that tile
-- (disabled by script: it keeps its connections but makes and uses nothing), to test what a
-- machine takes from the rest of the base; "clear@x:y" empties that machine's input and output
-- slots once (the player taking out what blocks it); "add@x:y::item*count" puts that many items
-- into the machine or chest on that tile once (the player handing in, say, more Water barrels);
-- "remove@x:y" takes away the entity on that tile (a machine, valve or Splitter; not a belt, pole or
-- resource), so that a later
-- "+name@x:y" in the same list can put something else there (a Pipe where a valve was).

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

-- Gas vents and Sinkholes: furnaces whose recipes void 20,000 of a fluid at a time.
local function batch_void(e)
  if e.type ~= "furnace" then return false end
  local c = e.prototype.crafting_categories or {}
  return c["py-venting"] or c["py-runoff"] or false
end

local function status_of(e)
  local ok, status = pcall(function() return e.status end)
  local s = ok and STATUS[status] or "-"
  if s == "no_ingredients" and batch_void(e) then s = "filling_batch" end
  return s
end

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

-- The recipe a machine runs, or for an idle furnace the one it ran last.
local function recipe_name(e)
  local r = e.get_recipe()
  if r then return r.name end
  if e.type == "furnace" and e.previous_recipe then
    local name = e.previous_recipe.name
    if type(name) ~= "string" then name = name.name end
    return name
  end
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
  return e.name .. " / " .. (recipe_name(e) or "-")
end

script.on_init(function()
  storage.sinks, storage.empties, storage.taken = {}, {}, {}
  local surface = game.surfaces.nauvis
  for name, x, y, dir, item in (PLACE or ""):gmatch("([%w%-_]+)@([%-%.%d]+):([%-%.%d]+):?(%a*):?([%w%-_%*]*)") do
    local pos = { tonumber(x), tonumber(y) }
    if name == "add" then
      local what, count = item:match("^([%w%-_]+)%*(%d+)$")
      local e = surface.find_entities_filtered({ position = pos,
        type = { "assembling-machine", "furnace", "container" } })[1]
      local n = (e and what) and e.insert({ name = what, count = tonumber(count) }) or 0
      out("add at %s,%s: %s %s×%d of %s", x, y, e and e.name or "NOTHING THERE", what or "?", n, count or "?")
    elseif name == "remove" then
      local e = surface.find_entities_filtered({ position = pos, type = { "transport-belt",
        "underground-belt", "electric-pole", "resource", "tree", "simple-entity" },
        invert = true })[1]
      local what = e and e.name or "NOTHING THERE"
      if e then e.destroy() end
      out("remove at %s,%s: %s", x, y, what)
    elseif name == "sink" or name == "empty" then
      local e = surface.find_entities_filtered({ position = pos,
        type = name == "sink" and { "transport-belt", "underground-belt" } or "container" })[1]
      table.insert(name == "sink" and storage.sinks or storage.empties, e)
      out("%s at %s,%s: %s", name, x, y, e and e.name or "NOTHING THERE")
    elseif name == "off" or name == "clear" then
      local e = surface.find_entities_filtered({ position = pos,
        type = { "transport-belt", "underground-belt", "splitter", "electric-pole", "pipe",
          "pipe-to-ground", "resource", "tree", "simple-entity" }, invert = true })[1]
      local what = ""
      if e and name == "off" then e.disabled_by_script = true end
      if e and name == "clear" then
        for _, kind in pairs({ "crafter_input", "crafter_output" }) do
          local inv = e.get_inventory(defines.inventory[kind])
          if inv then
            for i = 1, #inv do
              local s = inv[i]
              if s.valid_for_read then what = what .. string.format(" %s×%d", s.name, s.count) end
            end
            inv.clear()
          end
        end
      end
      out("%s at %s,%s: %s%s", name, x, y, e and e.name or "NOTHING THERE", what)
    else
      local e = surface.create_entity({ name = name, position = pos,
        direction = defines.direction[dir ~= "" and dir or "north"], force = "player" })
      if e and item ~= "" then
        if e.type == "assembling-machine" then
          e.set_recipe(item)
        elseif e.type == "infinity-pipe" then
          local fluid, temperature = item:match("^([%w%-_]+)%*?(%d*)$")
          e.set_infinity_pipe_filter({ name = fluid, percentage = 1,
            temperature = tonumber(temperature), mode = "at-least" })
        else
          e.use_filters = true
          e.inserter_filter_mode = "whitelist"
          e.set_filter(1, item)
        end
      end
      out("placed %s at %s,%s %s%s: %s", name, x, y, dir ~= "" and dir or "north",
        item ~= "" and " " .. item or "", e and "ok" or "FAILED")
    end
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
        -- A crafting machine's input slots too (which item it waits for).
        local items = {}
        local ok, inv = pcall(function() return e.get_inventory(defines.inventory.crafter_input) end)
        if ok and inv then
          for _, s in pairs(inv.get_contents()) do items[#items + 1] = string.format("%s %d", s.name, s.count) end
        end
        out("step %d s: %s at %s,%s: %s; fluid boxes: %s%s", t, e.name, x, y, status_of(e),
          table.concat(boxes, " | "), #items > 0 and "; input: " .. table.concat(items, ", ") or "")
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

-- What the sinks and emptied chests took, counted while measuring.
local function take(inventory)
  local t = game.tick - storage.start
  if t >= WARM * 60 and not storage.done then
    for _, s in pairs(inventory.get_contents()) do
      storage.taken[s.name] = (storage.taken[s.name] or 0) + s.count
    end
  end
  inventory.clear()
end

script.on_event(defines.events.on_tick, function()
  for _, belt in pairs(storage.sinks or {}) do
    if belt.valid then
      for i = 1, belt.get_max_transport_line_index() do take(belt.get_transport_line(i)) end
    end
  end
  if game.tick % 60 == 0 then
    for _, chest in pairs(storage.empties or {}) do
      if chest.valid then take(chest.get_inventory(defines.inventory.chest)) end
    end
  end
end)

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
    storage.voids = {}
    for _, e in pairs(storage.machines) do
      if batch_void(e) then
        local f = e.get_fluid(1)
        table.insert(storage.voids, { e = e, done = e.products_finished, box = f and f.amount or 0 })
      end
    end
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
      local s = status_of(e)
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
  if next(storage.taken) then
    local parts = {}
    for name, n in pairs(storage.taken) do parts[#parts + 1] = string.format("%s %.3f", name, n / MEASURE) end
    table.sort(parts)
    out("sinks and emptied chests took per s: %s", table.concat(parts, ", "))
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
  -- What flowed into each Gas vent and Sinkhole: the batches it voided plus what its box gained.
  for _, v in pairs(storage.voids or {}) do
    local e = v.e
    if e.valid then
      local name = recipe_name(e)
      local ing = name and prototypes.recipe[name].ingredients[1]
      local f = e.get_fluid(1)
      local batches = e.products_finished - v.done
      local inflow = (batches * (ing and ing.amount or 20000) + (f and f.amount or 0) - v.box) / MEASURE
      out("voided by %s at %s,%s: %s %.2f per s flowed in (%d batches; box %.0f)", e.name, e.position.x,
        e.position.y, ing and ing.name or (f and f.name) or "-", inflow, batches, f and f.amount or 0)
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
