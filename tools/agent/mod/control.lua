-- pt-agent: lets an AI agent play through RCON.
--
-- The agent is a character entity with no player behind it (a headless server has no players).
-- It gets what a new Py player gets: the freeplay start items and the Py Quick Start kit (power
-- armor with personal roboports, 100 construction robots), and the Far Reach bonuses.
--
-- Commands (sent through RCON by tools/agent/a.js): /agent <op> <json arguments>
-- The answer is JSON printed back to RCON. Ops are in lib/observe.lua (reading) and
-- lib/act.lua (acting); `_buf <text>` collects a long argument in parts, then `<op> @buf` uses it.
local util = require("lib.util")
local observe = require("lib.observe")
local act = require("lib.act")
local crash_site = require("crash-site")

local function surface() return game.surfaces.nauvis end

local function event(text)
  local line = util.fmt_time(game.tick) .. " " .. text
  table.insert(storage.events, line)
  if #storage.events > 50 then table.remove(storage.events, 1) end
  helpers.write_file("pt-agent/events.txt", line .. "\n", true)
end

local function chart_around(p, r)
  local s = surface()
  s.request_to_generate_chunks(p, math.ceil(r / 32) + 1)
  game.forces.player.chart(s, util.area_around(p, r))
end

local function apply_reach(c)
  local g = settings.global
  local function bonus(name) return g[name] and g[name].value or 0 end
  c.character_build_distance_bonus = bonus("far-reach-build-distance-bonus")
  c.character_reach_distance_bonus = bonus("far-reach-reach-distance-bonus")
  c.character_resource_reach_distance_bonus = bonus("far-reach-resource-reach-distance-bonus")
  c.character_item_drop_distance_bonus = bonus("far-reach-item-drop-distance-bonus")
  c.character_item_pickup_distance_bonus = bonus("far-reach-item-pickup-distance-bonus")
end

local function give_start_kit(c)
  if remote.interfaces.freeplay and remote.interfaces.freeplay.get_created_items then
    for name, count in pairs(remote.call("freeplay", "get_created_items")) do
      if prototypes.item[name] then c.insert { name = name, count = count } end
    end
  end
  if script.active_mods["py_quick_start"] then
    -- The same kit py_quick_start gives each player that joins.
    c.insert { name = "py-construction-robot-mk04", count = 100 }
    local armor = c.get_inventory(defines.inventory.character_armor)
    armor.insert { name = "power-armor-mk2", count = 1 }
    local grid = armor[1].grid
    grid.put { name = "night-vision-equipment" }
    grid.put { name = "belt-immunity-equipment" }
    for _ = 1, 55 do grid.put { name = "solar-panel-equipment" } end
    for _ = 1, 2 do grid.put { name = "exoskeleton-equipment" } end
    for _ = 1, 4 do grid.put { name = "personal-roboport-mk2-equipment" } end
    for _ = 1, 2 do grid.put { name = "quantum-battery" } end
  end
end

local function spawn_character(kit)
  local s = surface()
  local spawn = game.forces.player.get_spawn_position(s)
  s.request_to_generate_chunks(spawn, 4)
  s.force_generate_chunk_requests()
  local p = s.find_non_colliding_position("character", spawn, 100, 0.5) or spawn
  local c = s.create_entity { name = "character", position = p, force = "player" }
  storage.char = c
  apply_reach(c)
  if kit then give_start_kit(c) end
  chart_around(c.position, 200)
  return c
end

local function init_storage()
  storage.jobs = storage.jobs or {}
  storage.events = storage.events or {}
end

-- Freeplay creates the crashed ship (its wreckage holds plates and chests) when the first player
-- arrives, which never happens on a server without players: create it the same way.
local function create_crash_site()
  if storage.crash_site_created then return end
  local fp = remote.interfaces.freeplay
  if not (fp and fp.get_ship_items and fp.get_debris_items and fp.get_ship_parts) then return end
  crash_site.create_crash_site(surface(), { -5, -6 }, remote.call("freeplay", "get_ship_items"),
    remote.call("freeplay", "get_debris_items"), remote.call("freeplay", "get_ship_parts"))
  storage.crash_site_created = true
end

-- The advanced settings of Py's "py-recommended" map preset (data.raw["map-gen-presets"]).
-- Maps are created with the player's own map generation settings (that preset with cliffs
-- turned off), because `--preset` on the command line overrides `--map-gen-settings`.
local function apply_py_recommended()
  local ms = game.map_settings
  ms.pollution.enabled = false
  ms.enemy_evolution.time_factor = 2e-8
  ms.enemy_evolution.destroy_factor = 0.001
  ms.enemy_evolution.pollution_factor = 0
  ms.enemy_expansion.enabled = true
  ms.enemy_expansion.max_expansion_distance = 2
  ms.enemy_expansion.min_expansion_cooldown = 216000
  ms.enemy_expansion.max_expansion_cooldown = 648000
end

script.on_init(function()
  init_storage()
  apply_py_recommended()
  surface().request_to_generate_chunks({ 0, 0 }, 3)
  surface().force_generate_chunk_requests()
  create_crash_site()
  spawn_character(true)
  event("agent character created at " .. serpent.line(util.pos(storage.char.position)))
end)

script.on_configuration_changed(function()
  init_storage()
  if game.tick < 60 * 60 * 10 then create_crash_site() end
  if not (storage.char and storage.char.valid) then spawn_character(true) end
  apply_reach(storage.char)
end)

act.respawn = function()
  if storage.char and storage.char.valid then return { error = "the character is alive" } end
  spawn_character(false)
  event("character respawned (empty inventory)")
  return { pos = util.pos(storage.char.position) }
end

-- Jobs ------------------------------------------------------------------------------------------

local function finish(text)
  local j = table.remove(storage.jobs, 1)
  event((j and j.desc or "job") .. ": " .. text)
end

local function mining_ticks(c, e)
  local f = game.forces.player
  local speed = c.prototype.mining_speed * (1 + f.manual_mining_speed_modifier + c.character_mining_speed_modifier)
  return math.max(1, math.ceil(e.prototype.mineable_properties.mining_time / speed * 60))
end

local function next_mining_target(c, j)
  local s = surface()
  local centre = j.at or c.position
  local r = j.r or (j.at and 2) or 30
  local best, bd
  for _, e in pairs(s.find_entities_filtered { position = centre, radius = r, name = j.name, type = j.type }) do
    if e.minable and e.type ~= "character" and e.prototype.mineable_properties.minable then
      local limit = e.type == "resource" and c.resource_reach_distance or c.reach_distance
      local d = util.dist(e.position, centre)
      if util.dist(e.position, c.position) <= limit and (not bd or d < bd) then best, bd = e, d end
    end
  end
  return best
end

local function job_step()
  local j = storage.jobs[1]
  if not j then return end
  local c = storage.char
  if not (c and c.valid) then storage.jobs = {}; return end
  if j.kind == "walk" then
    if not j.due then
      local speed = c.character_running_speed
      if not speed or speed <= 0 then speed = 0.15 end
      j.due = game.tick + math.ceil(util.dist(c.position, j.to) / speed)
      surface().request_to_generate_chunks(j.to, 3)
    elseif game.tick >= j.due then
      local p = surface().find_non_colliding_position("character", j.to, 30, 0.5) or j.to
      c.teleport(p)
      chart_around(c.position, 200)
      finish("arrived at " .. util.pos(c.position).x .. "," .. util.pos(c.position).y)
    end
  elseif j.kind == "mine" then
    if j.target and not j.target.valid then j.target = nil end
    if j.target and game.tick >= j.due then
      local before = util.contents(c.get_main_inventory())
      -- On a resource, mine_entity yields one mining result and returns false while the
      -- resource is not used up; judge by what arrived in the inventory.
      local ok = c.mine_entity(j.target, false)
      local gained = false
      for k, v in pairs(util.contents(c.get_main_inventory())) do
        local d = v - (before[k] or 0)
        if d > 0 then j.got[k] = (j.got[k] or 0) + d; gained = true end
      end
      if not ok and not gained then
        finish("stopped after " .. j.done .. ": could not mine (inventory full?)")
        return
      end
      j.done = j.done + 1
      j.target = nil
    end
    if not j.target then
      if j.done >= j.count then finish("done, got " .. serpent.line(j.got)); return end
      local e = next_mining_target(c, j)
      if not e then finish("stopped after " .. j.done .. ": nothing left in reach, got " .. serpent.line(j.got)); return end
      j.target = e
      j.due = game.tick + mining_ticks(c, e)
    end
  end
end

script.on_event(defines.events.on_tick, function()
  if storage.jobs[1] then job_step() end
end)

script.on_nth_tick(600, function()
  local c = storage.char
  if c and c.valid then chart_around(c.position, 160) end
end)

script.on_event(defines.events.on_research_finished, function(e)
  event("research finished: " .. e.research.name)
end)

script.on_event(defines.events.on_entity_died, function(e)
  local ent = e.entity
  if ent == storage.char then
    storage.jobs = {}
    event("THE CHARACTER DIED at " .. serpent.line(util.pos(ent.position)) .. "; use respawn")
  elseif ent.force and ent.force.name == "player" then
    event(ent.name .. " destroyed at " .. serpent.line(util.pos(ent.position)))
  end
end)

-- Commands ----------------------------------------------------------------------------------------

local function run(param)
  local op, rest = (param or ""):match("^(%S+)%s*(.*)$")
  if not op then return { error = "usage: /agent <op> <json>" } end
  if op == "_buf" then
    storage.buf = (storage.buf or "") .. rest
    return { buffered = #storage.buf }
  end
  if rest == "@buf" then rest = storage.buf or ""; storage.buf = nil end
  local args = {}
  if rest ~= "" then
    args = helpers.json_to_table(rest)
    if type(args) ~= "table" then return { error = "arguments are not a JSON object: " .. rest:sub(1, 200) } end
  end
  local fn = observe[op] or act[op]
  if not fn then
    local names = {}
    for k in pairs(observe) do if type(observe[k]) == "function" and k ~= "entity_summary" then table.insert(names, k) end end
    for k in pairs(act) do table.insert(names, k) end
    table.sort(names)
    return { error = "unknown op " .. op, ops = names }
  end
  return fn(args)
end

commands.add_command("agent", "pt-agent: /agent <op> <json arguments>", function(cmd)
  local ok, res = pcall(run, cmd.parameter)
  if not ok then res = { error = tostring(res) } end
  local ok2, json = pcall(helpers.table_to_json, res)
  if not ok2 then json = helpers.table_to_json { error = "could not encode the answer: " .. tostring(json) } end
  rcon.print(json)
end)
