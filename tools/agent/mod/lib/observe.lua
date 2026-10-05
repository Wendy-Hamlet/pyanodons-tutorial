-- What the agent can read: its own state, the map around it, the factory and the tech tree.
-- Every function takes the command's argument table and returns a table (sent back as JSON);
-- a {text = ...} result is printed as plain text by the client.
local util = require("lib.util")
local observe = {}

local function surface() return game.surfaces.nauvis end
local function force() return game.forces.player end
local function char() local c = storage.char; return c and c.valid and c or nil end

local function center(a)
  local p = util.xy(a)
  if p then return p end
  local c = char()
  return c and util.pos(c.position) or { x = 0, y = 0 }
end

function observe.status(a)
  local c = char()
  local f = force()
  local out = { tick = game.tick, time = util.fmt_time(game.tick), paused = game.tick_paused, speed = game.speed }
  if c then
    out.pos = util.pos(c.position)
    local inv = c.get_main_inventory()
    out.inv = util.contents(inv)
    out.free_slots = inv.count_empty_stacks()
    out.crafting = {}
    for _, it in pairs(c.crafting_queue or {}) do
      if not it.prerequisite then table.insert(out.crafting, it.recipe .. " x" .. it.count) end
    end
    local net = c.logistic_network
    if net then
      out.robots = { available = net.available_construction_robots, total = net.all_construction_robots }
    end
  else
    out.character = "dead"
  end
  local r = f.current_research
  out.research = r and (r.name .. " " .. math.floor(f.research_progress * 100) .. "%") or "none"
  out.queue = {}
  for i, t in pairs(f.research_queue or {}) do if i > 1 then table.insert(out.queue, t.name) end end
  out.jobs = {}
  for _, j in pairs(storage.jobs) do table.insert(out.jobs, j.desc) end
  local ghosts = surface().count_entities_filtered { type = "entity-ghost", force = "player" }
  if ghosts > 0 then out.ghosts = ghosts end
  local decon = 0
  if c then
    decon = #surface().find_entities_filtered { area = util.area_around(c.position, 200), to_be_deconstructed = true }
  end
  if decon > 0 then out.to_deconstruct = decon end
  if a.events ~= false then
    out.events = storage.events
    storage.events = {}
  end
  return out
end

function observe.inv(a)
  local c = char()
  if not c then return { error = "no character" } end
  local out = {}
  for name, inv in pairs(util.inventories(c)) do
    local cont = util.contents(inv)
    if not util.is_empty(cont) then out[name] = cont end
  end
  local armor = c.get_inventory(defines.inventory.character_armor)
  if armor and armor[1] and armor[1].valid_for_read and armor[1].grid then
    local eq = {}
    for _, e in pairs(armor[1].grid.equipment) do eq[e.name] = (eq[e.name] or 0) + 1 end
    out.equipment = eq
  end
  out.reach = c.reach_distance
  out.build_distance = c.build_distance
  out.speed = c.character_running_speed
  return out
end

-- ASCII map: one char per tile.
function observe.look(a)
  local s = surface()
  local p = center(a)
  local w, h = math.min(a.w or 80, 200), math.min(a.h or 40, 120)
  local x0, y0 = math.floor(p.x - w / 2), math.floor(p.y - h / 2)
  local area = { { x0, y0 }, { x0 + w, y0 + h } }
  local grid = {}
  for j = 0, h - 1 do
    local row = {}
    for i = 0, w - 1 do row[i] = "." end
    grid[j] = row
  end
  local function put(tx, ty, ch, force_put)
    local i, j = tx - x0, ty - y0
    if i >= 0 and i < w and j >= 0 and j < h then
      if force_put or grid[j][i] == "." or grid[j][i] == "~" then grid[j][i] = ch end
    end
  end
  -- Ungenerated chunks are blank.
  for cy = math.floor(y0 / 32), math.floor((y0 + h - 1) / 32) do
    for cx = math.floor(x0 / 32), math.floor((x0 + w - 1) / 32) do
      if not s.is_chunk_generated { cx, cy } then
        for ty = cy * 32, cy * 32 + 31 do for tx = cx * 32, cx * 32 + 31 do put(tx, ty, " ", true) end end
      end
    end
  end
  for _, t in pairs(s.find_tiles_filtered { area = area, collision_mask = "water_tile" }) do
    put(t.position.x, t.position.y, "~", true)
  end
  local legend, codes = {}, {}
  local pool = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789#$&=!"
  local rpool = "abcdefghijklmnopqrsuwxyz"
  local nextc, nextr = 1, 1
  local function code(name, resource)
    if codes[name] then return codes[name] end
    local ch
    if resource then
      ch = rpool:sub(nextr, nextr); nextr = nextr + 1
    else
      ch = pool:sub(nextc, nextc); nextc = nextc + 1
    end
    if ch == "" then ch = "?" end
    codes[name] = ch
    legend[ch] = name
    return ch
  end
  local arrows = { [defines.direction.north] = "^", [defines.direction.east] = ">", [defines.direction.south] = "v", [defines.direction.west] = "<" }
  local function footprint(e, ch)
    local b = e.bounding_box
    for ty = math.floor(b.left_top.y + 0.05), math.ceil(b.right_bottom.y - 0.05) - 1 do
      for tx = math.floor(b.left_top.x + 0.05), math.ceil(b.right_bottom.x - 0.05) - 1 do put(tx, ty, ch, true) end
    end
  end
  for _, e in pairs(s.find_entities_filtered { area = area }) do
    local t = e.type
    if t == "resource" then
      put(math.floor(e.position.x), math.floor(e.position.y), code(e.name, true))
    elseif t == "tree" then
      put(math.floor(e.position.x), math.floor(e.position.y), "%")
    elseif t == "simple-entity" or t == "cliff" then
      footprint(e, "*")
    elseif t == "character" then
      -- drawn last
    elseif e.force.name == "player" then
      if t == "transport-belt" then
        put(math.floor(e.position.x), math.floor(e.position.y), arrows[e.direction] or "?", true)
      elseif t == "entity-ghost" then
        footprint(e, "?")
      else
        footprint(e, code(e.name))
      end
    end
  end
  local c = char()
  if c then put(math.floor(c.position.x), math.floor(c.position.y), "@", true) end
  local lines = {}
  table.insert(lines, string.format("map x %d..%d, y %d..%d (1 char = 1 tile; @ you, %% tree, * rock, ~ water, ? ghost, blank = ungenerated)", x0, x0 + w - 1, y0, y0 + h - 1))
  -- Column ruler: a mark every 10 tiles at multiples of 10.
  local ruler = {}
  for i = 0, w - 1 do
    local x = x0 + i
    ruler[i + 1] = (x % 10 == 0) and "|" or " "
  end
  table.insert(lines, "      " .. table.concat(ruler))
  for j = 0, h - 1 do
    local row = {}
    for i = 0, w - 1 do row[i + 1] = grid[j][i] end
    table.insert(lines, string.format("%5d ", y0 + j) .. table.concat(row))
  end
  local marks = {}
  for i = 0, w - 1 do
    local x = x0 + i
    if x % 10 == 0 then table.insert(marks, string.format("col %d = x %d", i, x)) end
  end
  table.insert(lines, "ruler: " .. table.concat(marks, ", "))
  local keys = {}
  for ch, name in pairs(legend) do table.insert(keys, ch .. "=" .. name) end
  table.sort(keys)
  table.insert(lines, "legend: " .. table.concat(keys, "  "))
  return { text = table.concat(lines, "\n") }
end

-- Resource patches around a point, clustered by name.
function observe.scan(a)
  local s = surface()
  local p = center(a)
  local r = math.min(a.r or 150, 600)
  local found = s.find_entities_filtered { area = util.area_around(p, r), type = "resource" }
  local by = {}
  for _, e in pairs(found) do
    local list = by[e.name]
    if not list then list = {}; by[e.name] = list end
    table.insert(list, { x = math.floor(e.position.x), y = math.floor(e.position.y), amount = e.amount })
  end
  local out = {}
  for name, tiles in pairs(by) do
    -- Union-find over tiles closer than 3 tiles apart.
    local index, parent = {}, {}
    local function key(x, y) return x * 100000 + y end
    for i, t in ipairs(tiles) do index[key(t.x, t.y)] = i; parent[i] = i end
    local function find(i)
      while parent[i] ~= i do parent[i] = parent[parent[i]]; i = parent[i] end
      return i
    end
    for i, t in ipairs(tiles) do
      for dx = -2, 2 do
        for dy = -2, 2 do
          local j = index[key(t.x + dx, t.y + dy)]
          if j then
            local ri, rj = find(i), find(j)
            if ri ~= rj then parent[ri] = rj end
          end
        end
      end
    end
    local patches = {}
    for i, t in ipairs(tiles) do
      local root = find(i)
      local pt = patches[root]
      if not pt then
        pt = { n = 0, amount = 0, sx = 0, sy = 0, x1 = t.x, y1 = t.y, x2 = t.x, y2 = t.y }
        patches[root] = pt
      end
      pt.n = pt.n + 1
      pt.amount = pt.amount + t.amount
      pt.sx, pt.sy = pt.sx + t.x, pt.sy + t.y
      pt.x1, pt.y1 = math.min(pt.x1, t.x), math.min(pt.y1, t.y)
      pt.x2, pt.y2 = math.max(pt.x2, t.x), math.max(pt.y2, t.y)
    end
    local list = {}
    for _, pt in pairs(patches) do
      local cx, cy = math.floor(pt.sx / pt.n), math.floor(pt.sy / pt.n)
      table.insert(list, {
        center = { cx, cy }, tiles = pt.n, amount = pt.amount,
        box = { pt.x1, pt.y1, pt.x2, pt.y2 }, dist = math.floor(util.dist({ cx, cy }, p)),
      })
    end
    table.sort(list, function(u, v) return u.dist < v.dist end)
    local keep = {}
    for i = 1, math.min(#list, a.per or 3) do keep[i] = list[i] end
    out[name] = { patches = #list, nearest = keep }
  end
  -- Rocks and trees nearby (rocks are where early Py stone and ores come from).
  local rocks = {}
  for _, e in pairs(s.find_entities_filtered { area = util.area_around(p, math.min(r, 100)), type = "simple-entity" }) do
    local d = util.dist(e.position, p)
    local rr = rocks[e.name]
    if not rr then rr = { count = 0, nearest = nil, d = 1e9 }; rocks[e.name] = rr end
    rr.count = rr.count + 1
    if d < rr.d then rr.d = d; rr.nearest = util.pos(e.position) end
  end
  for _, v in pairs(rocks) do v.d = math.floor(v.d) end
  local trees = s.count_entities_filtered { area = util.area_around(p, math.min(r, 100)), type = "tree" }
  return { center = p, radius = r, resources = out, rocks = rocks, trees_within_100 = trees }
end

local function entity_summary(e, full)
  local o = { n = e.name, p = util.pos(e.position) }
  if e.supports_direction then o.d = util.dir_names[e.direction] end
  if e.type == "entity-ghost" then o.ghost = e.ghost_name end
  local ok, rec = pcall(function() return e.get_recipe and e.get_recipe() end)
  if ok and rec then o.r = rec.name end
  if e.status then o.s = util.status_names[e.status] end
  if full then
    local invs = {}
    for name, inv in pairs(util.inventories(e)) do
      local cont = util.contents(inv)
      if not util.is_empty(cont) then invs[name] = cont end
    end
    if not util.is_empty(invs) then o.inv = invs end
    if e.fluids_count > 0 then
      local fl = {}
      for name, amount in pairs(e.get_fluid_contents()) do fl[name] = math.floor(amount) end
      if not util.is_empty(fl) then o.fluids = fl end
    end
    if e.type == "assembling-machine" or e.type == "furnace" then o.progress = math.floor(e.crafting_progress * 100) end
    if e.type == "mining-drill" and e.mining_target then o.target = e.mining_target.name end
    if e.drop_target then o.drop = e.drop_target.name end
  end
  return o
end
observe.entity_summary = entity_summary

-- Player-force entities near a point; name/type filters; full=true adds inventories.
function observe.entities(a)
  local p = center(a)
  local r = a.r or 20
  local list = surface().find_entities_filtered {
    area = util.area_around(p, r), force = "player", name = a.name, type = a.type,
  }
  local out = {}
  for _, e in pairs(list) do
    if e.type ~= "character" then
      table.insert(out, entity_summary(e, a.full ~= false))
      if #out >= (a.limit or 60) then break end
    end
  end
  return { count = #list, entities = out }
end

-- Every machine of the force, counted by name and status; problems listed with positions.
function observe.factory(a)
  local types = { "assembling-machine", "furnace", "mining-drill", "lab", "boiler", "generator", "offshore-pump", "inserter", "reactor", "burner-generator" }
  local counts, problems = {}, {}
  local ok_status = { working = true, normal = true, waiting_for_source_items = true, waiting_for_space_in_destination = true }
  for _, e in pairs(surface().find_entities_filtered { force = "player", type = types }) do
    local st = e.status and util.status_names[e.status] or "?"
    local key = e.name
    local c = counts[key]
    if not c then c = {}; counts[key] = c end
    c[st] = (c[st] or 0) + 1
    if not ok_status[st] and e.type ~= "inserter" then
      local pk = e.name .. ":" .. st
      local pr = problems[pk]
      if not pr then pr = {}; problems[pk] = pr end
      if #pr < (a.per or 4) then table.insert(pr, util.pos(e.position)) end
    end
  end
  return { machines = counts, problems = problems }
end

-- Production and consumption per minute over a window (one_minute, ten_minutes, one_hour...).
function observe.prod(a)
  local s, f = surface(), force()
  local prec = defines.flow_precision_index[a.window or "ten_minutes"]
  local out = {}
  local function read(stats, kind)
    local names = {}
    for k in pairs(stats.input_counts) do names[type(k) == "table" and k.name or k] = true end
    for k in pairs(stats.output_counts) do names[type(k) == "table" and k.name or k] = true end
    for name in pairs(names) do
      local made = stats.get_flow_count { name = name, category = "input", precision_index = prec }
      local used = stats.get_flow_count { name = name, category = "output", precision_index = prec }
      if made > 0.01 or used > 0.01 then
        out[kind .. ":" .. name] = { made = math.floor(made * 10 + 0.5) / 10, used = math.floor(used * 10 + 0.5) / 10 }
      end
    end
  end
  read(f.get_item_production_statistics(s), "item")
  if a.fluids then read(f.get_fluid_production_statistics(s), "fluid") end
  return { per_minute = out, window = a.window or "ten_minutes" }
end

local machines_by_category
local function machines_for(categories)
  if not machines_by_category then
    machines_by_category = {}
    for name, p in pairs(prototypes.get_entity_filtered { { filter = "crafting-machine" } }) do
      for cat in pairs(p.crafting_categories or {}) do
        machines_by_category[cat] = machines_by_category[cat] or {}
        table.insert(machines_by_category[cat], name)
      end
    end
  end
  local out, seen = {}, {}
  for _, cat in pairs(categories) do
    for _, m in pairs(machines_by_category[cat] or {}) do
      if not seen[m] then seen[m] = true; table.insert(out, m) end
    end
  end
  return out
end

local function product_text(p)
  local amount = p.amount or ((p.amount_min or 0) .. "-" .. (p.amount_max or 0))
  local chance = p.probability or p.independent_probability
  local s = p.name .. " x" .. amount
  if chance and chance < 1 then s = s .. " @" .. math.floor(chance * 1000) / 10 .. "%" end
  if p.type == "fluid" then s = "(f)" .. s end
  return s
end

local function recipe_summary(r, f)
  local ing, prod = {}, {}
  for _, i in pairs(r.ingredients) do table.insert(ing, product_text(i)) end
  for _, p in pairs(r.products) do table.insert(prod, product_text(p)) end
  local hand = false
  local c = char()
  local cats = c and c.prototype.crafting_categories or {}
  for _, cat in pairs(r.categories) do if cats[cat] then hand = true end end
  local made_in = machines_for(r.categories)
  if #made_in > 6 then made_in = { made_in[1], made_in[2], made_in[3], "+" .. (#made_in - 3) } end
  return {
    name = r.name, enabled = f.recipes[r.name].enabled, category = table.concat(r.categories, ","), time = r.energy,
    ing = table.concat(ing, ", "), out = table.concat(prod, ", "), hand = hand, made_in = made_in,
  }
end

-- Recipes by name, product or ingredient (enabled only unless all=true).
function observe.recipe(a)
  local f = force()
  if a.name then
    local r = prototypes.recipe[a.name]
    if not r then return { error = "no recipe " .. a.name } end
    return recipe_summary(r, f)
  end
  local out = {}
  for name, r in pairs(prototypes.recipe) do
    if a.all or f.recipes[name].enabled then
      local hit = false
      if a.product then for _, p in pairs(r.products) do if p.name == a.product then hit = true end end end
      if a.ingredient then for _, p in pairs(r.ingredients) do if p.name == a.ingredient then hit = true end end end
      if hit then table.insert(out, recipe_summary(r, f)) end
    end
  end
  return { recipes = out }
end

local function tech_summary(t)
  local ing = {}
  for _, i in pairs(t.research_unit_ingredients) do table.insert(ing, i.name .. " x" .. i.amount) end
  local unlocks = {}
  for _, e in pairs(t.prototype.effects or {}) do
    if e.type == "unlock-recipe" then table.insert(unlocks, e.recipe) end
  end
  local pre = {}
  for name in pairs(t.prerequisites) do table.insert(pre, name) end
  return {
    name = t.name, researched = t.researched, units = t.research_unit_count, unit_time = t.research_unit_energy / 60,
    cost = table.concat(ing, ", "), unlocks = unlocks, prerequisites = pre,
    trigger = t.prototype.research_trigger,
  }
end

-- One technology, or every technology that can be researched now.
function observe.tech(a)
  local f = force()
  if a.name then
    local t = f.technologies[a.name]
    if not t then return { error = "no technology " .. a.name } end
    return tech_summary(t)
  end
  local out = {}
  for _, t in pairs(f.technologies) do
    if t.enabled and not t.researched then
      local ready = true
      for _, pre in pairs(t.prerequisites) do if not pre.researched then ready = false; break end end
      if ready then
        local s = tech_summary(t)
        s.prerequisites = nil
        table.insert(out, s)
      end
    end
  end
  table.sort(out, function(u, v) return u.name < v.name end)
  return { available = out }
end

-- Prototype facts: entity (size, speed, power, fuel) or item (stack, fuel value, places).
function observe.proto(a)
  -- Prototype attributes differ by type and some error when absent: read them safely.
  local function get(p, k) local ok, v = pcall(function() return p[k] end); if ok then return v end end
  local out = {}
  local e = prototypes.entity[a.name]
  if e then
    local usage = get(e, "energy_usage")
    out.entity = {
      type = e.type, size = { e.tile_width, e.tile_height }, crafting_speed = get(e, "crafting_speed"),
      mining_speed = get(e, "mining_speed"), energy_usage_kw = usage and usage * 60 / 1000 or nil,
      burner = get(e, "burner_prototype") and e.burner_prototype.fuel_categories or nil,
      electric = get(e, "electric_energy_source_prototype") ~= nil, modules = get(e, "module_inventory_size"),
      categories = get(e, "crafting_categories"), resource_categories = get(e, "resource_categories"),
    }
  end
  local i = prototypes.item[a.name]
  if i then
    out.item = { stack = i.stack_size, fuel_mj = i.fuel_value > 0 and i.fuel_value / 1e6 or nil, places = i.place_result and i.place_result.name or nil }
  end
  if not e and not i then return { error = "no entity or item " .. tostring(a.name) } end
  return out
end


-- The fluid boxes of the entity at x/y as the engine sees them: for each storage its recipe
-- filter, what it holds, and every pipe connection (the tile it faces and what is there).
-- Read this before piping a machine: box numbers in the prototype do not say which fluid of a
-- recipe goes where, the filters do (a machine needs its recipe set first).
function observe.boxes(a)
  local e = surface().find_entities_filtered { position = { a.x, a.y }, force = "player", limit = 1 }[1]
    or error("no entity at " .. a.x .. "," .. a.y)
  local out = { name = e.name, direction = e.direction, recipe = e.get_recipe and e.type ~= "pipe" and e.get_recipe() and e.get_recipe().name or nil, boxes = {} }
  for i = 1, e.fluids_count do
    local box = { }
    local ok, filt = pcall(e.get_fluid_filter, i)
    box.filter = ok and filt and filt.fluid and (type(filt.fluid) == "string" and filt.fluid or filt.fluid.name) or nil
    local fl = e.get_fluid(i)
    box.holds = fl and (fl.name .. " " .. math.floor(fl.amount)) or nil
    local ok2, cons = pcall(e.get_fluid_box_pipe_connections, i)
    if ok2 then
      box.connections = {}
      for _, c in pairs(cons) do
        local t = c.target
        table.insert(box.connections, string.format("%s %.1f,%.1f -> %.1f,%.1f %s", c.flow_direction, c.position.x, c.position.y,
          c.target_position.x, c.target_position.y, t and t.valid and t.name or "-"))
      end
    end
    out.boxes[i] = box
  end
  return out
end

return observe
