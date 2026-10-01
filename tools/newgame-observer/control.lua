-- Records what a brand-new game offers, during map creation (--create): starting items from the
-- freeplay scenario, recipes and technologies available at tick 0, crash-site entities and the
-- resource patches around spawn. Writes script-output/cellforge/newgame-report.json.

local RADIUS = 320 -- tiles around spawn to scan for resources

local function freeplay_items()
  local out = {}
  local api = remote.interfaces.freeplay
  if not api then return out end
  for _, fn in ipairs({ "get_created_items", "get_respawn_items", "get_debris_items", "get_ship_items" }) do
    if api[fn] then out[fn] = remote.call("freeplay", fn) end
  end
  return out
end

local function start_state(force)
  local recipes, researched, available = {}, {}, {}
  for name, recipe in pairs(force.recipes) do
    if recipe.enabled and not recipe.prototype.hidden then recipes[#recipes + 1] = name end
  end
  for name, tech in pairs(force.technologies) do
    if tech.researched then
      researched[#researched + 1] = name
    elseif tech.enabled and not tech.prototype.hidden then
      local ready = true
      for _, pre in pairs(tech.prerequisites) do ready = ready and pre.researched end
      if ready then available[#available + 1] = name end
    end
  end
  table.sort(recipes)
  table.sort(researched)
  table.sort(available)
  return recipes, researched, available
end

local function resources(surface, spawn)
  local area = { { spawn.x - RADIUS, spawn.y - RADIUS }, { spawn.x + RADIUS, spawn.y + RADIUS } }
  local buckets = {}
  for _, r in pairs(surface.find_entities_filtered({ type = "resource", area = area })) do
    local cx, cy = math.floor(r.position.x / 32), math.floor(r.position.y / 32)
    local key = r.name .. "@" .. cx .. "," .. cy
    local b = buckets[key]
    if not b then
      b = { name = r.name, cx = cx, cy = cy, tiles = 0, amount = 0 }
      buckets[key] = b
    end
    b.tiles = b.tiles + 1
    b.amount = b.amount + r.amount
  end
  local out = {}
  for _, b in pairs(buckets) do out[#out + 1] = b end
  return out
end

script.on_init(function()
  local surface = game.surfaces.nauvis
  local force = game.forces.player
  local spawn = force.get_spawn_position(surface)
  surface.request_to_generate_chunks(spawn, math.ceil(RADIUS / 32) + 1)
  surface.force_generate_chunk_requests()

  local recipes, researched, available = start_state(force)
  local site = {}
  for _, e in pairs(surface.find_entities_filtered({ position = spawn, radius = 64, force = { "player", "neutral" } })) do
    if e.type ~= "resource" and e.type ~= "tree" and e.type ~= "simple-entity" and e.type ~= "fish" then
      site[#site + 1] = { name = e.name, type = e.type, x = e.position.x, y = e.position.y }
    end
  end

  local report = {
    spawn = spawn,
    freeplay = freeplay_items(),
    recipes = recipes,
    researched = researched,
    available = available,
    character_crafting_categories = prototypes.entity.character.crafting_categories,
    crash_site = site,
    resources = resources(surface, spawn),
    radius = RADIUS,
  }
  helpers.write_file("cellforge/newgame-report.json", helpers.table_to_json(report))
  log("CF-NEWGAME wrote report: " .. #recipes .. " recipes, " .. #available .. " technologies available")
end)
