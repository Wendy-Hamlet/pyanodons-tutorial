-- Read-only snapshot of a save. tools/inspect-save.ps1 loads a COPY of the save in an isolated
-- Factorio setup with this mod added; on the first tick it writes
-- script-output/cellforge/save-report.json and entities.json, and changes nothing in the world.
-- `config` in the report is what the game said changed when loading the save here (this mod
-- itself excluded); inspect-save.ps1 uses it to check the setup matches the save.

local function safe(fn)
  local ok, value = pcall(fn)
  if ok then return value end
  return { error = tostring(value) }
end

local function contents(inventory)
  local out = {}
  if inventory then
    for _, c in pairs(inventory.get_contents()) do
      out[#out + 1] = { name = c.name, count = c.count, quality = c.quality }
    end
  end
  return out
end

local function technologies(force)
  local researched, available = {}, {}
  for name, tech in pairs(force.technologies) do
    if tech.researched then
      researched[#researched + 1] = name
    elseif tech.enabled and not tech.prototype.hidden then
      local ready = true
      for _, pre in pairs(tech.prerequisites) do ready = ready and pre.researched end
      if ready then available[#available + 1] = name end
    end
  end
  table.sort(researched)
  table.sort(available)
  local queue = {}
  for _, tech in pairs(force.research_queue or {}) do queue[#queue + 1] = tech.name end
  return {
    researched = researched,
    available = available,
    current = force.current_research and force.current_research.name,
    progress = force.research_progress,
    queue = queue,
  }
end

-- The advanced map settings a map preset can set (MapSettings and DifficultySettings are
-- LuaStructs, which table_to_json cannot write, so the fields are copied by name).
local ADVANCED = {
  pollution = { "enabled", "diffusion_ratio", "min_to_diffuse", "ageing", "expected_max_per_chunk",
    "min_to_show_per_chunk", "min_pollution_to_damage_trees", "pollution_with_max_forest_damage",
    "pollution_per_tree_damage", "pollution_restored_per_tree_damage",
    "enemy_attack_pollution_consumption_modifier" },
  enemy_evolution = { "enabled", "time_factor", "destroy_factor", "pollution_factor" },
  enemy_expansion = { "enabled", "max_expansion_distance", "friendly_base_influence_radius",
    "enemy_building_influence_radius", "building_coefficient", "other_base_coefficient",
    "neighbouring_chunk_coefficient", "neighbouring_base_chunk_coefficient",
    "max_colliding_tiles_coefficient", "settler_group_min_size", "settler_group_max_size",
    "min_expansion_cooldown", "max_expansion_cooldown", "min_expansion_distance",
    "build_base_unit_dispatch_cooldown" },
}

local function advanced_settings()
  local out = {}
  for group, keys in pairs(ADVANCED) do
    out[group] = {}
    for _, key in ipairs(keys) do out[group][key] = game.map_settings[group][key] end
  end
  local d = game.difficulty_settings
  out.difficulty_settings = {
    technology_price_multiplier = d.technology_price_multiplier, spoil_time_modifier = d.spoil_time_modifier,
  }
  return out
end

local function players()
  local out = {}
  for _, player in pairs(game.players) do
    local queue = {}
    for _, item in pairs(player.crafting_queue or {}) do queue[#queue + 1] = { recipe = item.recipe, count = item.count } end
    out[#out + 1] = {
      name = player.name,
      position = player.position,
      surface = player.surface.name,
      controller = player.controller_type,
      inventory = contents(player.get_main_inventory()),
      crafting_queue = queue,
    }
  end
  return out
end

local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end
local DIRECTION = {}
for k, v in pairs(defines.direction) do DIRECTION[v] = k end

local function item_count(inventory)
  return inventory and inventory.get_item_count() or nil
end

-- { item = count } of an inventory, nil when empty or absent.
local function counts(inventory)
  if not inventory then return nil end
  local out = {}
  for _, c in pairs(inventory.get_contents()) do out[c.name] = (out[c.name] or 0) + c.count end
  return next(out) and out or nil
end

local function entities(surface)
  local list, box = {}, nil
  for _, e in pairs(surface.find_entities_filtered({ force = "player" })) do
    if e.type ~= "character" then
      local b = e.bounding_box
      local entry = {
        name = e.name, type = e.type, x = e.position.x, y = e.position.y,
        x1 = b.left_top.x, y1 = b.left_top.y, x2 = b.right_bottom.x, y2 = b.right_bottom.y,
        dir = DIRECTION[e.direction],
      }
      local ok, status = pcall(function() return e.status end)
      if ok and status then entry.status = STATUS[status] end
      if e.type == "assembling-machine" or e.type == "furnace" then
        local recipe = e.get_recipe()
        entry.recipe = recipe and recipe.name
        -- What waits inside: shows machines stocked by hand and products nobody takes out.
        entry.input = counts(e.get_inventory(defines.inventory.crafter_input))
        entry.output = counts(e.get_inventory(defines.inventory.crafter_output))
        -- Machines with an output port (soil and sap extractors, wood processing units...) drop
        -- their products themselves, onto a belt or straight into the machine standing there.
        if e.prototype.vector_to_place_result then
          entry.drop = e.drop_position
          entry.drop_to = e.drop_target and e.drop_target.name
        end
      elseif e.type == "mining-drill" then
        entry.target = e.mining_target and e.mining_target.name
        entry.drop = e.drop_position
        -- Ore still under the drill, per resource: a drill with none left has stopped for good.
        entry.ore = {}
        for _, r in pairs(surface.find_entities_filtered({ area = e.mining_area, type = "resource" })) do
          entry.ore[r.name] = (entry.ore[r.name] or 0) + r.amount
        end
        if not next(entry.ore) then entry.ore = nil end
      elseif e.type == "inserter" then
        entry.pickup, entry.drop = e.pickup_position, e.drop_position
        if e.use_filters then
          local f = e.get_filter(1)
          entry.filter = f and (type(f) == "table" and f.name or f)
          entry.filter_mode = e.inserter_filter_mode -- "whitelist" or "blacklist"
        end
      elseif e.type == "container" or e.type == "logistic-container" then
        entry.items = counts(e.get_inventory(defines.inventory.chest))
      elseif e.type == "underground-belt" then
        entry.ug = e.belt_to_ground_type
      elseif e.type == "entity-ghost" then
        entry.ghost = e.ghost_name -- what the robots still have to build
      end
      -- Fluids: what each fluid storage holds and which connected segment it belongs to (pipes and
      -- machines sharing a segment id are joined).
      local nf = e.fluids_count
      if nf and nf > 0 then
        entry.fluid_boxes = {}
        for i = 1, nf do
          local f = e.get_fluid(i)
          local seg = e.has_fluid_segment(i) and e.get_fluid_segment_id(i) or nil
          entry.fluid_boxes[#entry.fluid_boxes + 1] = { index = i, fluid = f and f.name, amount = f and math.floor(f.amount), segment = seg }
        end
      end
      -- Items on belts, both lanes together.
      if e.type == "transport-belt" or e.type == "underground-belt" then
        local items = {}
        for line = 1, e.get_max_transport_line_index() do
          for _, c in pairs(e.get_transport_line(line).get_contents()) do items[c.name] = (items[c.name] or 0) + c.count end
        end
        if next(items) then entry.items = items end
      end
      if e.burner then
        entry.fuel = item_count(e.burner.inventory)
        entry.burnt = item_count(e.burner.burnt_result_inventory)
      end
      list[#list + 1] = entry
      if not box then
        box = { x1 = b.left_top.x, y1 = b.left_top.y, x2 = b.right_bottom.x, y2 = b.right_bottom.y }
      else
        box.x1, box.y1 = math.min(box.x1, b.left_top.x), math.min(box.y1, b.left_top.y)
        box.x2, box.y2 = math.max(box.x2, b.right_bottom.x), math.max(box.y2, b.right_bottom.y)
      end
    end
  end
  return list, box
end

---Resource amounts around the base, bucketed per chunk so patches can be located.
local function resources(surface, box, margin)
  local area = { { box.x1 - margin, box.y1 - margin }, { box.x2 + margin, box.y2 + margin } }
  local buckets = {}
  for _, r in pairs(surface.find_entities_filtered({ type = "resource", area = area })) do
    local key = r.name .. "@" .. math.floor(r.position.x / 32) .. "," .. math.floor(r.position.y / 32)
    local b = buckets[key]
    if not b then
      b = { name = r.name, cx = math.floor(r.position.x / 32), cy = math.floor(r.position.y / 32), tiles = 0, amount = 0 }
      buckets[key] = b
    end
    b.tiles = b.tiles + 1
    b.amount = b.amount + r.amount
  end
  local out = {}
  for _, b in pairs(buckets) do out[#out + 1] = b end
  return out, area
end

local function flow(stats)
  return { produced = stats.input_counts, consumed = stats.output_counts }
end

---Mining outposts: drills grouped by mined resource and closeness (within 12 tiles, transitively).
local function outposts(surface)
  local drills = {}
  for _, d in pairs(surface.find_entities_filtered({ force = "player", type = "mining-drill" })) do
    if d.mining_target then drills[#drills + 1] = d end
  end
  local parent = {}
  local function find(i)
    while parent[i] ~= i do parent[i] = parent[parent[i]]; i = parent[i] end
    return i
  end
  for i = 1, #drills do parent[i] = i end
  for i = 1, #drills do
    for j = i + 1, #drills do
      local a, b = drills[i], drills[j]
      if a.mining_target.name == b.mining_target.name
        and math.abs(a.position.x - b.position.x) <= 12 and math.abs(a.position.y - b.position.y) <= 12 then
        parent[find(i)] = find(j)
      end
    end
  end
  local groups = {}
  for i, d in ipairs(drills) do
    local root = find(i)
    local g = groups[root]
    if not g then
      g = { resource = d.mining_target.name, drills = {}, x1 = math.huge, y1 = math.huge, x2 = -math.huge, y2 = -math.huge }
      groups[root] = g
    end
    g.drills[#g.drills + 1] = d
    local b = d.bounding_box
    g.x1, g.y1 = math.min(g.x1, b.left_top.x), math.min(g.y1, b.left_top.y)
    g.x2, g.y2 = math.max(g.x2, b.right_bottom.x), math.max(g.y2, b.right_bottom.y)
  end
  local list = {}
  for _, g in pairs(groups) do list[#list + 1] = g end
  table.sort(list, function(a, b) return a.x1 < b.x1 end)
  return list
end

local MARGIN = 8

local function resource_amount(surface, g)
  local n = 0
  for _, r in pairs(surface.find_entities_filtered({ type = "resource", name = g.resource,
    area = { { g.x1, g.y1 }, { g.x2, g.y2 } } })) do n = n + r.amount end
  return n
end

local function export_outposts(surface, groups)
  local out = {}
  local inv = game.create_inventory(1)
  for i, g in ipairs(groups) do
    local area = { { math.floor(g.x1) - MARGIN, math.floor(g.y1) - MARGIN }, { math.ceil(g.x2) + MARGIN, math.ceil(g.y2) + MARGIN } }
    local stack = inv[1]
    stack.set_stack({ name = "blueprint" })
    stack.create_blueprint({ surface = surface, force = "player", area = area })
    out[i] = {
      resource = g.resource, drills = #g.drills, area = area,
      blueprint = stack.is_blueprint_setup() and stack.export_stack() or nil,
    }
    stack.clear()
  end
  inv.destroy()
  return out
end

local SAMPLE_EVERY, MEASURE_TICKS = 60, 3600

-- After the snapshot, keep sampling outpost drills so a longer run (inspect-save.ps1 -Ticks) can
-- measure real mining rates and how often drills stand still.
local function sample(surface)
  local m = storage.measure
  for _, g in ipairs(m.groups) do
    for _, d in ipairs(g.drills) do
      if d.valid then
        local s = STATUS[d.status] or "?"
        g.status_samples[s] = (g.status_samples[s] or 0) + 1
      end
    end
  end
  if game.tick - m.start >= MEASURE_TICKS then
    local result = {}
    for i, g in ipairs(m.groups) do
      result[i] = {
        resource = g.resource, drills = #g.drills,
        mined_per_second = (g.amount0 - resource_amount(surface, g)) / (MEASURE_TICKS / 60),
        status_samples = g.status_samples,
      }
    end
    helpers.write_file("cellforge/outpost-measure.json", helpers.table_to_json(result))
    log("CF-INSPECT wrote outpost measurement over " .. MEASURE_TICKS .. " ticks")
    storage.measure = nil
  end
end

-- Raised when this mod is added, after on_init; also lists every other difference.
script.on_configuration_changed(function(data)
  local changes = {}
  for name, change in pairs(data.mod_changes) do
    if name ~= script.mod_name then changes[name] = { old = change.old_version, new = change.new_version } end
  end
  storage.config = {
    mod_changes = next(changes) and changes or nil, -- an empty table would become a JSON array
    startup_settings_changed = data.mod_startup_settings_changed,
    game_old = data.old_version, game_new = data.new_version,
  }
end)

script.on_event(defines.events.on_tick, function()
  local surface = game.surfaces.nauvis
  if storage.measure then
    if game.tick % SAMPLE_EVERY == 0 then sample(surface) end
    return
  end
  if storage.done then return end
  storage.done = true
  local groups = outposts(surface)
  helpers.write_file("cellforge/outposts.json", helpers.table_to_json(export_outposts(surface, groups)))
  storage.measure = { start = game.tick, groups = {} }
  for _, g in ipairs(groups) do
    storage.measure.groups[#storage.measure.groups + 1] = {
      resource = g.resource, drills = g.drills, x1 = g.x1, y1 = g.y1, x2 = g.x2, y2 = g.y2,
      amount0 = resource_amount(surface, g), status_samples = {},
    }
  end
  local surface = game.surfaces.nauvis
  local force = game.forces.player
  local list, box = entities(surface)
  local report = {
    tick = game.tick,
    ticks_played = game.ticks_played,
    config = storage.config,
    mods = script.active_mods,
    map = safe(function()
      local s = surface.map_gen_settings
      return { seed = s.seed, starting_area = s.starting_area, autoplace_controls = s.autoplace_controls,
        no_enemies = s.no_enemies_mode, peaceful = s.peaceful_mode }
    end),
    -- Complete settings, usable as --map-gen-settings to recreate this world.
    map_gen_settings = safe(function() return surface.map_gen_settings end),
    advanced_settings = safe(advanced_settings),
    enemy_expansion = safe(function() return game.map_settings.enemy_expansion.enabled end),
    technology_price_multiplier = safe(function() return game.difficulty_settings.technology_price_multiplier end),
    pollution = safe(function() return surface.get_total_pollution() end),
    research = technologies(force),
    players = players(),
    base_box = box,
    items = safe(function() return flow(force.get_item_production_statistics(surface)) end),
    fluids = safe(function() return flow(force.get_fluid_production_statistics(surface)) end),
  }
  -- Resource tiles per resource over everything generated so far (is it on this map at all?).
  report.resource_tiles = safe(function()
    local out = {}
    for name in pairs(prototypes.get_entity_filtered({ { filter = "type", type = "resource" } })) do
      local n = surface.count_entities_filtered({ name = name })
      if n > 0 then out[name] = n end
    end
    return out
  end)
  if box then
    report.resources, report.resource_area = resources(surface, box, 160)
    report.enemies_near = surface.count_entities_filtered({ force = "enemy", area = report.resource_area })
  end
  helpers.write_file("cellforge/save-report.json", helpers.table_to_json(report))
  helpers.write_file("cellforge/entities.json", helpers.table_to_json(list))
  log("CF-INSPECT wrote report: " .. #list .. " entities")
end)
