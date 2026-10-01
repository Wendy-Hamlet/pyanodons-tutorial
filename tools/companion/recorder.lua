-- Play recorder. Writes what happens in a game to
-- script-output/py-tutorial-companion/recorder/<map seed>-<tick the recorder started>/:
--   timeline.jsonl       research started/finished/cancelled, chat, console commands, mod and
--                        game version changes. Small, never rotated.
--   activity-NNNN.jsonl  a "minute" line every minute (player positions; per surface what was
--                        built by hand or by robots, ghosts placed, mined, died, tiles; machines
--                        with positions; items crafted by hand) and a "production" line every 10
--                        minutes (items and fluids produced/consumed since the previous one).
--                        Split into segments by size; only the newest segments are kept.
-- Every line has the game tick `t` and kind `k`. Loading an earlier save rewinds `t`: readers drop
-- the abandoned lines (t >= the rewound tick) and segments older than the one before them
-- (tools/recorder-summary.js does both).

local recorder = {}

local MINUTE = 3600
local PRODUCTION_EVERY = 10 -- minutes
local MACHINE_TYPES = {
  ["assembling-machine"] = true, ["furnace"] = true, ["mining-drill"] = true, ["lab"] = true,
  ["boiler"] = true, ["generator"] = true, ["burner-generator"] = true, ["reactor"] = true,
  ["rocket-silo"] = true, ["offshore-pump"] = true, ["roboport"] = true, ["train-stop"] = true,
  ["beacon"] = true,
}

local function enabled() return settings.global["pt-recorder-enabled"].value end

local function folder() return "py-tutorial-companion/recorder/" .. storage.recorder.run end

local function segment_file(n) return string.format("%s/activity-%04d.jsonl", folder(), n) end

local function timeline(kind, fields)
  if not enabled() then return end
  fields.t, fields.k = game.tick, kind
  helpers.write_file(folder() .. "/timeline.jsonl", helpers.table_to_json(fields) .. "\n", true)
end

local function activity(fields)
  if not enabled() then return end
  local r = storage.recorder
  local text = helpers.table_to_json(fields) .. "\n"
  local limit = r.test_segment_bytes or settings.global["pt-recorder-segment-mb"].value * 1048576
  local keep = r.test_keep or settings.global["pt-recorder-keep-segments"].value
  if r.bytes > 0 and r.bytes + #text > limit then
    r.segment, r.bytes = r.segment + 1, 0
    while r.oldest <= r.segment - keep do
      helpers.remove_path(segment_file(r.oldest))
      r.oldest = r.oldest + 1
    end
  end
  -- A new segment starts with a fresh file: one left over from an abandoned branch is replaced.
  helpers.write_file(segment_file(r.segment), text, r.bytes > 0)
  r.bytes = r.bytes + #text
end

-- Minute accumulators -------------------------------------------------------------------------

local function bucket(surface)
  local m = storage.recorder.minute
  m.surfaces = m.surfaces or {}
  local b = m.surfaces[surface.name]
  if not b then
    b = {}
    m.surfaces[surface.name] = b
  end
  return b
end

local function add(b, group, key, n)
  local g = b[group]
  if not g then
    g = {}
    b[group] = g
  end
  g[key] = (g[key] or 0) + (n or 1)
end

local function extend_area(b, p)
  local a = b.area
  if not a then
    b.area = { p.x, p.y, p.x, p.y }
    return
  end
  if p.x < a[1] then a[1] = p.x end
  if p.y < a[2] then a[2] = p.y end
  if p.x > a[3] then a[3] = p.x end
  if p.y > a[4] then a[4] = p.y end
end

local function built(entity, group)
  if not (entity and entity.valid) then return end
  local b = bucket(entity.surface)
  if entity.type == "entity-ghost" then
    add(b, "ghosts", entity.ghost_name)
  elseif entity.type == "tile-ghost" then
    add(b, "ghosts", "tile/" .. entity.ghost_name)
  else
    add(b, group, entity.name)
    if MACHINE_TYPES[entity.type] then
      b.machines = b.machines or {}
      b.machines[#b.machines + 1] = { entity.name, entity.position.x, entity.position.y }
    end
  end
  extend_area(b, entity.position)
end

local function mined(entity, group)
  if not (entity and entity.valid) then return end
  local name = entity.name
  if entity.type == "tree" then
    name = "tree"
  elseif entity.type == "entity-ghost" or entity.type == "tile-ghost" then
    group, name = "ghosts_removed", entity.ghost_name
  end
  add(bucket(entity.surface), group, name)
end

local function tiles(surface_index, group, name, count)
  add(bucket(game.get_surface(surface_index) --[[@as LuaSurface]]), group, name, count)
end

-- Production --------------------------------------------------------------------------------------

local SIDES = { { "input_counts", "produced" }, { "output_counts", "consumed" } }

--- Counts since the previous call, per surface; updates the stored totals. Fluids to 0.1.
local function production_since_last()
  local r = storage.recorder
  local force = game.forces.player
  local result = {}
  for _, surface in pairs(game.surfaces) do
    local last = r.flows[surface.name] or {}
    r.flows[surface.name] = last
    local entry = {}
    for kind, stats in pairs({
      items = force.get_item_production_statistics(surface),
      fluids = force.get_fluid_production_statistics(surface),
    }) do
      for _, side in ipairs(SIDES) do
        local key = kind .. "_" .. side[2]
        local counts, previous = stats[side[1]], last[key] or {}
        local delta, any = {}, false
        for name, count in pairs(counts) do
          local d = count - (previous[name] or 0)
          if kind == "fluids" then d = math.floor(d * 10 + 0.5) / 10 end
          if d ~= 0 then
            delta[name], any = d, true
          end
        end
        last[key] = counts
        if any then entry[key] = delta end
      end
    end
    if next(entry) then result[surface.name] = entry end
  end
  return result
end

-- Bootstrap ----------------------------------------------------------------------------------------

function recorder.on_init()
  local seed = game.surfaces.nauvis.map_gen_settings.seed
  storage.recorder = {
    run = string.format("%d-%d", seed, game.tick),
    segment = 1, oldest = 1, bytes = 0, minute = {}, flows = {},
  }
  production_since_last() -- baseline: the first production line counts from here
  timeline("start", { seed = seed, mods = script.active_mods })
end

function recorder.on_configuration_changed(data)
  if not storage.recorder then
    recorder.on_init()
    return
  end
  local changes = {}
  for name, change in pairs(data.mod_changes) do
    changes[name] = { change.old_version or "", change.new_version or "" }
  end
  timeline("config", {
    game = { data.old_version or "", data.new_version or "" },
    mods_changed = changes,
    startup_settings_changed = data.mod_startup_settings_changed,
    migration_applied = data.migration_applied,
    mods = script.active_mods,
  })
end

function recorder.on_minute(event)
  local r = storage.recorder
  local m = r.minute
  m.t, m.k = event.tick, "minute"
  for _, player in pairs(game.connected_players) do
    m.players = m.players or {}
    local p = player.position
    m.players[player.name] = { math.floor(p.x + 0.5), math.floor(p.y + 0.5), player.surface.name }
  end
  activity(m)
  r.minute = {}
  if (event.tick / MINUTE) % PRODUCTION_EVERY == 0 then
    local surfaces = production_since_last()
    if next(surfaces) then activity({ t = event.tick, k = "production", surfaces = surfaces }) end
  end
end

--- For tools/check-recorder.ps1: tiny segments, so rotation happens within minutes.
function recorder.set_test_limits(segment_bytes, keep)
  storage.recorder.test_segment_bytes, storage.recorder.test_keep = segment_bytes, keep
end

function recorder.register()
  local e = defines.events
  script.on_nth_tick(MINUTE, recorder.on_minute)
  script.on_event(e.on_built_entity, function(event) built(event.entity, "built") end)
  script.on_event(e.on_robot_built_entity, function(event) built(event.entity, "robot_built") end)
  script.on_event(e.on_player_mined_entity, function(event) mined(event.entity, "mined") end)
  script.on_event(e.on_robot_mined_entity, function(event) mined(event.entity, "robot_mined") end)
  script.on_event(e.on_entity_died, function(event)
    local entity = event.entity
    if entity.valid and entity.force.name ~= "neutral" and entity.force.name ~= "enemy" then
      add(bucket(entity.surface), "died", entity.name)
    end
  end)
  script.on_event(e.on_player_built_tile, function(event)
    tiles(event.surface_index, "tiles", event.tile.name, #event.tiles)
  end)
  script.on_event(e.on_robot_built_tile, function(event)
    tiles(event.surface_index, "tiles", event.tile.name, #event.tiles)
  end)
  script.on_event(e.on_player_mined_tile, function(event)
    for _, t in pairs(event.tiles) do tiles(event.surface_index, "tiles_mined", t.old_tile.name) end
  end)
  script.on_event(e.on_player_crafted_item, function(event)
    local m = storage.recorder.minute
    m.crafted = m.crafted or {}
    local stack = event.item_stack
    m.crafted[stack.name] = (m.crafted[stack.name] or 0) + stack.count
  end)
  script.on_event(e.on_research_started, function(event)
    timeline("research_started", { name = event.research.name, level = event.research.level })
  end)
  script.on_event(e.on_research_finished, function(event)
    timeline("research_finished", {
      name = event.research.name, level = event.research.level, by_script = event.by_script or nil,
    })
  end)
  script.on_event(e.on_research_cancelled, function(event)
    timeline("research_cancelled", { names = event.research })
  end)
  script.on_event(e.on_console_chat, function(event)
    local player = event.player_index and game.get_player(event.player_index)
    timeline("chat", { player = player and player.name or nil, message = event.message })
  end)
  script.on_event(e.on_console_command, function(event)
    local player = event.player_index and game.get_player(event.player_index)
    timeline("command", {
      player = player and player.name or nil, command = event.command,
      parameters = event.parameters ~= "" and event.parameters:sub(1, 200) or nil,
    })
  end)
end

return recorder
