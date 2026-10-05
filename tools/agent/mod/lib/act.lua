-- What the agent can do. Everything goes through the character: items come from and go to its
-- inventory, actions need reach (the player's Far Reach bonuses apply), hand mining and walking
-- take the time they would take (jobs, run one at a time by control.lua), crafting uses the
-- character's crafting queue, and ghosts are built by the construction robots of its armor.
local util = require("lib.util")
local observe = require("lib.observe")
local act = {}

local function surface() return game.surfaces.nauvis end
local function force() return game.forces.player end

local function need_char()
  local c = storage.char
  if not (c and c.valid) then error("the character is dead; respawn with `respawn`") end
  return c
end

local function need_xy(a)
  local p = util.xy(a)
  if not p then error("give x and y") end
  return p
end

local function check_reach(c, p, limit, what)
  local d = util.dist(c.position, p)
  if d > limit then
    error(string.format("%s at %.1f,%.1f is %.0f tiles away, reach is %.0f: walk closer first", what or "target", p.x, p.y, d, limit))
  end
end

local function target(a, c)
  local p = need_xy(a)
  local e = util.entity_at(surface(), p, a.name)
  if not e then error(string.format("no entity%s at %s,%s", a.name and (" " .. a.name) or "", p.x, p.y)) end
  check_reach(c, e.position, c.reach_distance, e.name)
  return e
end

local function direction(a)
  if a.dir == nil then return defines.direction.north end
  return util.dirs[a.dir] or tonumber(a.dir) or error("dir is N, E, S or W")
end

local function blockers(name, p, dir)
  local proto = prototypes.entity[name]
  local box = proto.collision_box
  local w = math.max(box.right_bottom.x - box.left_top.x, box.right_bottom.y - box.left_top.y) / 2
  local found = {}
  for _, e in pairs(surface().find_entities_filtered { area = { { p.x - w, p.y - w }, { p.x + w, p.y + w } } }) do
    if e.type ~= "resource" then table.insert(found, e.name .. "@" .. util.pos(e.position).x .. "," .. util.pos(e.position).y) end
  end
  local tile = surface().get_tile(p.x, p.y)
  return table.concat(found, " ") .. " tile=" .. tile.name
end

-- Place one entity from the inventory.
function act.place(a)
  local c = need_char()
  local name = a.name or error("give name")
  if not prototypes.entity[name] then error("unknown entity " .. name) end
  local item = util.place_item(name) or error("no item places " .. name)
  if c.get_item_count(item) < 1 then error("no " .. item .. " in the inventory") end
  local p = need_xy(a)
  check_reach(c, p, c.build_distance, name)
  local dir = direction(a)
  local s = surface()
  if not s.can_place_entity { name = name, position = p, direction = dir, force = "player", build_check_type = defines.build_check_type.manual } then
    error("cannot place " .. name .. " at " .. p.x .. "," .. p.y .. ": " .. blockers(name, p, dir))
  end
  -- An assembler only keeps its direction when created with a recipe (fluid boxes).
  local e = s.create_entity {
    name = name, position = p, direction = dir, force = "player", raise_built = true,
    create_build_effect_smoke = false, move_stuck_players = true, type = a.ug,
    recipe = prototypes.entity[name].type == "assembling-machine" and a.recipe or nil,
  }
  if not e then error("create_entity failed") end
  c.remove_item { name = item, count = 1 }
  if a.recipe then e.set_recipe(a.recipe) end
  return observe.entity_summary(e, false)
end

-- Ghosts for the robots: one entity (name, x, y, dir, recipe) or a list in `list`, offset by
-- ox, oy. Trees and rocks in the way are marked for deconstruction.
function act.ghost(a)
  local s = surface()
  local list = a.list or { a }
  local ox, oy = a.ox or 0, a.oy or 0
  local made, failed = 0, {}
  for _, g in pairs(list) do
    local p = { x = g.x + ox, y = g.y + oy }
    local dir = direction(g)
    local proto = prototypes.entity[g.name]
    if not proto then
      table.insert(failed, "unknown " .. tostring(g.name))
    else
      local box = proto.collision_box
      local w = math.max(box.right_bottom.x - box.left_top.x, box.right_bottom.y - box.left_top.y) / 2
      for _, o in pairs(s.find_entities_filtered { area = { { p.x - w, p.y - w }, { p.x + w, p.y + w } }, type = { "tree", "simple-entity", "item-entity" } }) do
        o.order_deconstruction("player")
      end
      if s.can_place_entity { name = g.name, position = p, direction = dir, force = "player", build_check_type = defines.build_check_type.manual_ghost } then
        local e = s.create_entity { name = "entity-ghost", inner_name = g.name, position = p, direction = dir, force = "player", type = g.ug }
        if e then
          made = made + 1
          if g.recipe then pcall(e.set_recipe, g.recipe) end
          -- Inserter filters: filters = {"ash", ...}, filter_mode = "whitelist" | "blacklist"
          if g.filters then
            pcall(function() e.use_filters = true end)
            for i, f in ipairs(g.filters) do pcall(e.set_filter, i, f) end
            if g.filter_mode then pcall(function() e.inserter_filter_mode = g.filter_mode end) end
          end
        else
          table.insert(failed, g.name .. "@" .. p.x .. "," .. p.y)
        end
      else
        table.insert(failed, g.name .. "@" .. p.x .. "," .. p.y .. " blocked: " .. blockers(g.name, p, dir))
      end
    end
  end
  return { ghosts = made, failed = failed }
end

-- Ghosts from a blueprint string (from the client, possibly uploaded in parts).
function act.blueprint(a)
  local inv = game.create_inventory(1)
  local stack = inv[1]
  local ok = stack.import_stack(a.string or error("give string"))
  if ok == 1 then inv.destroy(); error("blueprint import failed") end
  local ghosts = stack.build_blueprint {
    surface = surface(), force = "player", position = need_xy(a), direction = direction(a),
    build_mode = defines.build_mode.superforced, skip_fog_of_war = false,
  }
  inv.destroy()
  return { ghosts = #ghosts }
end

-- Build ghosts in reach straight from the inventory (when robots cannot).
function act.build_ghosts(a)
  local c = need_char()
  local r = math.min(a.r or 30, c.build_distance)
  local built, missing = 0, {}
  for _, g in pairs(surface().find_entities_filtered { area = util.area_around(c.position, r), type = "entity-ghost", force = "player" }) do
    local item = util.place_item(g.ghost_name)
    if item and c.get_item_count(item) > 0 then
      local _, e = g.revive { raise_revive = true }
      if e then
        c.remove_item { name = item, count = 1 }
        built = built + 1
      end
    else
      missing[item or g.ghost_name] = (missing[item or g.ghost_name] or 0) + 1
    end
  end
  return { built = built, missing = missing }
end

-- Mark trees, rocks or own entities in a box for the robots to deconstruct.
function act.clear(a)
  local p = need_xy(a)
  local w, h = a.w or 10, a.h or a.w or 10
  local area = { { p.x, p.y }, { p.x + w, p.y + h } }
  local types = a.own and nil or { "tree", "simple-entity", "item-entity" }
  local n = 0
  for _, e in pairs(surface().find_entities_filtered { area = area, type = types, name = a.name }) do
    if (a.own and e.force.name == "player" and e.type ~= "character") or (not a.own) then
      if e.order_deconstruction("player") then n = n + 1 end
    end
  end
  return { marked = n }
end

function act.cancel_clear(a)
  local n = 0
  for _, e in pairs(surface().find_entities_filtered { to_be_deconstructed = true }) do
    e.cancel_deconstruction("player"); n = n + 1
  end
  return { cancelled = n }
end

-- Pick up an own entity into the inventory.
function act.remove(a)
  local c = need_char()
  local e = target(a, c)
  local name = e.name
  if not c.mine_entity(e, true) then error("could not mine " .. name) end
  return { removed = name }
end

function act.rotate(a)
  local c = need_char()
  local e = target(a, c)
  e.rotate { reverse = a.reverse }
  return observe.entity_summary(e, false)
end

function act.set_recipe(a)
  local c = need_char()
  local e = target(a, c)
  local removed = e.set_recipe(a.recipe)
  for _, it in pairs(removed or {}) do c.insert { name = it.name, count = it.count, quality = it.quality } end
  return observe.entity_summary(e, false)
end

-- Move items into an entity.
function act.insert(a)
  local c = need_char()
  local e = target(a, c)
  local item = a.item or error("give item")
  local have = c.get_item_count(item)
  local want = math.min(a.count or have, have)
  if want <= 0 then error("no " .. item .. " in the inventory") end
  local n = e.insert { name = item, count = want }
  if n > 0 then c.remove_item { name = item, count = n } end
  return { inserted = n, into = e.name }
end

-- Inventories that hold what a machine or chest gives out. By name: the numeric ids overlap
-- (defines.inventory.chest and .fuel are both 1).
local output_inventories = { crafter_output = true, chest = true, burnt_result = true }

local function take_from(c, e, item, count, all_inventories)
  local got = {}
  for i = 1, e.get_max_inventory_index() do
    local inv = e.get_inventory(i)
    if inv and inv.valid and (all_inventories or output_inventories[inv.name]) then
      for _, it in pairs(inv.get_contents()) do
        if (not item or it.name == item) and (count == nil or count > 0) then
          local n = math.min(it.count, count or it.count)
          local moved = c.insert { name = it.name, count = n, quality = it.quality }
          if moved > 0 then
            inv.remove { name = it.name, count = moved, quality = it.quality }
            got[it.name] = (got[it.name] or 0) + moved
            if count then count = count - moved end
          end
        end
      end
    end
  end
  return got
end

-- Take items out of an entity (outputs and chests; all=true includes inputs and fuel).
function act.take(a)
  local c = need_char()
  local e = target(a, c)
  return { took = take_from(c, e, a.item, a.count, a.all) }
end

local function around(a, c)
  local p = util.xy(a) or util.pos(c.position)
  local r = math.min(a.r or 30, c.reach_distance)
  check_reach(c, p, c.reach_distance + r, "area")
  -- any=true also reaches entities of other forces (the crashed ship's wreckage).
  return surface().find_entities_filtered { area = util.area_around(p, r), force = (not a.any) and "player" or nil, name = a.names, type = a.types }
end

-- Collect outputs (and chest contents with chests=true, items on the ground with ground=true).
function act.collect(a)
  local c = need_char()
  local total = {}
  for _, e in pairs(around(a, c)) do
    if e.type ~= "character" and (a.chests or a.any or (e.type ~= "container" and e.type ~= "logistic-container")) then
      for k, v in pairs(take_from(c, e, a.item, nil, false)) do total[k] = (total[k] or 0) + v end
    end
  end
  if a.ground then
    local p = util.xy(a) or c.position
    for _, it in pairs(surface().find_entities_filtered { area = util.area_around(p, math.min(a.r or 30, c.reach_distance)), type = "item-entity" }) do
      local st = it.stack
      if st and st.valid_for_read and (not a.item or st.name == a.item) then
        local name = st.name
        local moved = c.insert(st)
        if moved > 0 then
          total[name] = (total[name] or 0) + moved
          if moved >= st.count then it.destroy() else st.count = st.count - moved end
        end
      end
    end
  end
  return { collected = total }
end

-- Top up every burner in range to `count` of fuel `item`.
-- Tops a burner up to `target` fuel items (any fuel counts). When its slots hold another fuel
-- that blocks ours, that fuel goes back to the character first, as a player would swap it.
local function top_up(c, b, fuel, target)
  local inv = b.inventory
  local want = target - inv.get_item_count()
  if want <= 0 then return 0, false end
  local have = c.get_item_count(fuel)
  if have <= 0 then return 0, true end
  local moved = inv.insert { name = fuel, count = math.min(want, have) }
  if moved == 0 then
    for _, it in pairs(inv.get_contents()) do
      if it.name ~= fuel then
        local back = c.insert { name = it.name, count = it.count, quality = it.quality }
        if back > 0 then inv.remove { name = it.name, count = back, quality = it.quality } end
      end
    end
    moved = inv.insert { name = fuel, count = math.min(target, have) }
  end
  if moved > 0 then c.remove_item { name = fuel, count = moved } end
  return moved, moved < want
end

function act.fuel(a)
  local c = need_char()
  local item = a.item or error("give item")
  local per = a.count or 5
  local given, n = 0, 0
  for _, e in pairs(around(a, c)) do
    local b = e.burner
    if b and e.type ~= "character" then
      if c.get_item_count(item) <= 0 then break end
      local moved = top_up(c, b, item, per)
      if moved > 0 then given, n = given + moved, n + 1 end
    end
  end
  return { fuelled = n, gave = given, left = c.get_item_count(item) }
end

-- Does an inserter take items out of this entity?
local function taken_by_inserter(e)
  local b = e.bounding_box
  for _, ins in pairs(e.surface.find_entities_filtered {
    type = "inserter", area = { { b.left_top.x - 1.5, b.left_top.y - 1.5 }, { b.right_bottom.x + 1.5, b.right_bottom.y + 1.5 } },
  }) do
    if ins.pickup_target == e then return true end
  end
  return false
end

-- Store an item in a chest, keeping `keep` (default 0) in the inventory.
function act.stash(a)
  local c = need_char()
  local e = target(a, c)
  local item = a.item or error("give item")
  local extra = c.get_item_count(item) - (a.keep or 0)
  if extra <= 0 then return { stored = 0 } end
  local n = e.insert { name = item, count = extra }
  if n > 0 then c.remove_item { name = item, count = n } end
  return { stored = n, item = item }
end

-- Store everything but buildings in the chests listed in `chests` ([[x, y], ...]), keeping up to
-- `keep[item]` of each item in the inventory.
function act.stash_all(a)
  local c = need_char()
  local keep = a.keep or {}
  local chests = {}
  for _, p in pairs(a.chests or error("give chests")) do
    table.insert(chests, target({ x = p[1], y = p[2] }, c))
  end
  local stored = {}
  for _, it in pairs(c.get_main_inventory().get_contents()) do
    local proto = prototypes.item[it.name]
    if not proto.place_result and not keep[it.name .. "!"] then
      local extra = c.get_item_count(it.name) - (keep[it.name] or 0)
      for _, ch in pairs(chests) do
        if extra <= 0 then break end
        local n = ch.insert { name = it.name, count = extra }
        if n > 0 then
          c.remove_item { name = it.name, count = n }
          extra = extra - n
          stored[it.name] = (stored[it.name] or 0) + n
        end
      end
    end
  end
  return { stored = stored, free_slots = c.get_main_inventory().count_empty_stacks() }
end

-- The other direction: every item of `keep` that is below three quarters of its amount in the
-- inventory is taken back from the `chests` up to that amount.
function act.restock(a)
  local c = need_char()
  local chests = {}
  for _, p in pairs(a.chests or error("give chests")) do
    table.insert(chests, target({ x = p[1], y = p[2] }, c))
  end
  local got = {}
  for item, amount in pairs(a.keep or {}) do
    if prototypes.item[item] then
      local want = amount - c.get_item_count(item)
      if want > amount / 4 then
        for _, ch in pairs(chests) do
          if want <= 0 then break end
          local inv = ch.get_inventory(defines.inventory.chest)
          local have = inv.get_item_count(item)
          if have > 0 then
            local n = c.insert { name = item, count = math.min(have, want) }
            if n > 0 then
              inv.remove { name = item, count = n }
              want = want - n
              got[item] = (got[item] or 0) + n
            end
          end
        end
      end
    end
  end
  return { restocked = got }
end

-- Mark chests (list of {x, y} in `at`, or x/y) as input chests: upkeep never empties them.
-- off=true unmarks.
function act.input_chest(a)
  storage.input_chests = storage.input_chests or {}
  local c = need_char()
  local out = {}
  for _, p in pairs(a.at or { { a.x, a.y } }) do
    local e = target({ x = p[1] or p.x, y = p[2] or p.y }, c)
    storage.input_chests[e.unit_number] = (not a.off) or nil
    table.insert(out, e.name .. "@" .. e.position.x .. "," .. e.position.y)
  end
  return { marked = out, off = a.off }
end

-- One round of chores: take every output, Ash (only from slots holding 600 or more) and chest
-- content in range (keep=a,b leaves those items in chests), then top up every burner with `fuel` (default raw-coal): mining drills to
-- `drills` (default 10), everything else to `others` (default 5).
function act.upkeep(a)
  local c = need_char()
  local keep = {}
  for _, k in pairs(a.keep or {}) do keep[k] = true end
  local got = {}
  local list = around({ x = a.x, y = a.y, r = a.r or 160 }, c)
  local inputs = storage.input_chests or {}
  for _, e in pairs(list) do
    if e.type ~= "character" and not inputs[e.unit_number] then
      for i = 1, e.get_max_inventory_index() do
        local inv = e.get_inventory(i)
        -- An assembler's output is left to the inserter that takes it to the next machine.
        local skip = e.type == "assembling-machine" and inv and inv.name == "crafter_output" and not a.assemblers
          and taken_by_inserter(e)
        if inv and inv.valid and output_inventories[inv.name] and not skip then
          for _, it in pairs(inv.get_contents()) do
            -- Ash and other burnt results are only taken once the slot is filling up: taking a
            -- few hundred from every burner each round filled the inventory before the outputs
            -- that matter were reached.
            local burnt_low = inv.name == "burnt_result" and it.count < 600
            if not (inv.name == "chest" and keep[it.name]) and not burnt_low then
              local moved = c.insert { name = it.name, count = it.count, quality = it.quality }
              if moved > 0 then
                inv.remove { name = it.name, count = moved, quality = it.quality }
                got[it.name] = (got[it.name] or 0) + moved
              end
            end
          end
        end
      end
    end
  end
  local fuel = a.fuel or "raw-coal"
  local gave, short = 0, 0
  for _, e in pairs(list) do
    local b = e.type ~= "character" and e.burner
    if b then
      local moved, is_short = top_up(c, b, fuel, e.type == "mining-drill" and (a.drills or 10) or (a.others or 5))
      gave = gave + moved
      if is_short then short = short + 1 end
    end
  end
  return { got = got, fuel_given = gave, burners_short = short, fuel_left = c.get_item_count(fuel) }
end

-- Put `count` of an ingredient into every machine in range (names/types filter) that takes it.
function act.feed(a)
  local c = need_char()
  local item = a.item or error("give item")
  local per = a.count or 10
  local given, n = 0, 0
  for _, e in pairs(around(a, c)) do
    if e.type == "assembling-machine" or e.type == "furnace" or e.type == "lab" or e.type == "container" or e.type == "boiler" then
      local have = c.get_item_count(item)
      if have <= 0 then break end
      local inside = e.get_item_count(item)
      if inside < per then
        local ok, moved = pcall(e.insert, { name = item, count = math.min(per - inside, have) })
        if ok and moved > 0 then
          c.remove_item { name = item, count = moved }
          given, n = given + moved, n + 1
        end
      end
    end
  end
  return { fed = n, gave = given, left = c.get_item_count(item) }
end

function act.craft(a)
  local c = need_char()
  local recipe = a.recipe or a.name or error("give recipe")
  local r = prototypes.recipe[recipe] or error("unknown recipe " .. recipe)
  local started = c.begin_crafting { recipe = recipe, count = a.count or 1, silent = true }
  local out = { started = started }
  if started < (a.count or 1) then
    out.need = {}
    for _, i in pairs(r.ingredients) do
      out.need[i.name] = i.amount .. " each, have " .. c.get_item_count(i.name)
    end
    if not force().recipes[recipe].enabled then out.reason = "recipe not researched" end
  end
  return out
end

function act.craft_cancel(a)
  local c = need_char()
  local q = c.crafting_queue or {}
  local idx = a.index or #q
  if not q[idx] then return { cancelled = 0 } end
  c.cancel_crafting { index = idx, count = a.count or q[idx].count }
  return { cancelled = q[idx].recipe }
end

-- Timed jobs: walk and hand-mine. They queue behind each other.
function act.walk(a)
  local c = need_char()
  local p = need_xy(a)
  table.insert(storage.jobs, { kind = "walk", to = p, desc = "walk to " .. p.x .. "," .. p.y })
  return { queued = #storage.jobs }
end

function act.mine(a)
  need_char()
  local job = {
    kind = "mine", name = a.name, type = a.type, count = a.count or 1, done = 0, got = {},
    at = util.xy(a), r = a.r,
  }
  job.desc = "mine " .. (a.name or a.type or "?") .. " x" .. job.count
  table.insert(storage.jobs, job)
  return { queued = #storage.jobs }
end

function act.stop(a)
  storage.jobs = {}
  return { jobs = 0 }
end

function act.research(a)
  local f = force()
  local out = {}
  if a.set then
    f.research_queue = a.set
  end
  for _, name in pairs(type(a.add) == "table" and a.add or (a.add and { a.add } or {})) do
    out[name] = f.add_research(name)
  end
  if a.cancel then f.research_queue = {} end
  local q = {}
  for _, t in pairs(f.research_queue or {}) do table.insert(q, t.name) end
  out.queue = q
  return out
end

function act.speed(a)
  game.speed = math.max(0.1, math.min(a.value or 1, 8))
  return { speed = game.speed }
end

function act.pause(a)
  game.tick_paused = a.value ~= false
  return { paused = game.tick_paused, tick = game.tick }
end

function act.note(a)
  local line = string.format("[%s] %s", util.fmt_time(game.tick), a.text or "")
  helpers.write_file("pt-agent/notes.txt", line .. "\n", true)
  return { noted = line }
end

-- Diagnostics only: run a Lua expression and return its value (read the world, never cheat).
function act.eval(a)
  local fn, err = load("return " .. (a.code or "nil"), "eval", "t", setmetatable({ c = storage.char, s = surface(), f = force() }, { __index = _G }))
  if not fn then fn, err = load(a.code, "eval", "t", setmetatable({ c = storage.char, s = surface(), f = force() }, { __index = _G })) end
  if not fn then error(err) end
  local v = fn()
  if type(v) == "userdata" then v = tostring(v) end
  return { value = v }
end

return act
