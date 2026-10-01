-- Builds candidate early-game designs next to test fixtures (infinite sources, counting sinks),
-- runs them, reports throughput and problems, and exports each design as a blueprint string.
-- Results are CF-LAB log lines. Coordinates are tile coordinates; +y is south.

local N, E, S, W = defines.direction.north, defines.direction.east, defines.direction.south, defines.direction.west
local VEC = { [N] = { 0, -1 }, [E] = { 1, 0 }, [S] = { 0, 1 }, [W] = { -1, 0 } }
local T_WARM = 3600   -- rates are measured after this tick
local T_END = 18000   -- rates reported; supply to the smelting columns is then cut
local T_DRAIN = 25200 -- ore and fuel still on the belts now can never be used

local function out(fmt, ...) log("CF-LAB " .. string.format(fmt, ...)) end

local surface
local function place(spec, what)
  spec.force = "player"
  local e = surface.create_entity(spec)
  if not e then out("BUILD FAILED: %s at (%.1f, %.1f)", what or spec.name, spec.position[1], spec.position[2]) end
  return e
end

local function belt(x, y, dir) return place({ name = "transport-belt", position = { x + 0.5, y + 0.5 }, direction = dir }) end
local function belts(x, y1, y2, dir) for y = math.min(y1, y2), math.max(y1, y2) do belt(x, y, dir) end end
local function underground(x, y, dir, kind)
  return place({ name = "underground-belt", position = { x + 0.5, y + 0.5 }, direction = dir, type = kind }, "underground " .. kind)
end

-- Mechanical inserter at tile (x, y) picking up from the side `from` (N/E/S/W), optionally filtered.
local function inserter(x, y, from, filter)
  local e = place({ name = "burner-inserter", position = { x + 0.5, y + 0.5 }, direction = N })
  if not e then return nil end
  local v = VEC[from]
  local want = { x = x + 0.5 + v[1], y = y + 0.5 + v[2] }
  for _, d in ipairs({ N, E, S, W }) do
    e.direction = d
    local p = e.pickup_position
    if math.abs(p.x - want.x) < 0.6 and math.abs(p.y - want.y) < 0.6 then break end
  end
  if filter then
    e.use_filters = true
    e.set_filter(1, filter)
  end
  return e
end

-- 2x2 entities addressed by their top-left tile.
local function furnace(x, y) return place({ name = "stone-furnace", position = { x + 1, y + 1 } }) end
local function drill(x, y, dir) return place({ name = "burner-mining-drill", position = { x + 1, y + 1 }, direction = dir }) end
local function chest(x, y) return place({ name = "iron-chest", position = { x + 0.5, y + 0.5 } }) end

local function ore(name, x1, y1, x2, y2)
  for x = x1, x2 do for y = y1, y2 do
    surface.create_entity({ name = name, position = { x + 0.5, y + 0.5 }, amount = 1000000 })
  end end
end

-- Fixtures (not part of any design): infinite source into belt tile (x, y) flowing `dir`,
-- and a counting sink taking everything from belt tile (x, y) flowing `dir`.
local fixtures = {}
local function fixture(e) if e then fixtures[e.unit_number] = true end return e end
local function source(x, y, dir, item)
  local v = VEC[dir]
  local loader = fixture(place({ name = "loader", position = { x + 0.5 - 1.5 * v[1], y + 0.5 - 1.5 * v[2] }, direction = dir, type = "output" }, "source loader"))
  local c = fixture(place({ name = "infinity-chest", position = { x + 0.5 - 3 * v[1], y + 0.5 - 3 * v[2] } }, "source chest"))
  c.set_infinity_container_filter(1, { name = item, count = 50, mode = "exactly" })
  return loader
end

-- Items of `item` on all belt-like entities in a column of tiles (x, y1..y2), every lane.
local function on_belts(x, y1, y2, item)
  local n = 0
  for _, b in pairs(surface.find_entities_filtered({ area = { { x, y1 }, { x + 1, y2 + 1 } }, type = { "transport-belt", "underground-belt" } })) do
    for line = 1, b.get_max_transport_line_index() do n = n + b.get_transport_line(line).get_item_count(item) end
  end
  return n
end
-- Items of `item` on all belt-like entities in a tile area, every lane.
local function on_area(x1, y1, x2, y2, item)
  local n = 0
  for _, b in pairs(surface.find_entities_filtered({ area = { { x1, y1 }, { x2 + 1, y2 + 1 } }, type = { "transport-belt", "underground-belt" } })) do
    for line = 1, b.get_max_transport_line_index() do n = n + b.get_transport_line(line).get_item_count(item) end
  end
  return n
end
local function sink(x, y, dir)
  local v = VEC[dir]
  fixture(place({ name = "loader", position = { x + 0.5 + 1.5 * v[1], y + 0.5 + 1.5 * v[2] }, direction = dir, type = "input" }, "sink loader"))
  return fixture(place({ name = "iron-chest", position = { x + 0.5 + 3 * v[1], y + 0.5 + 3 * v[2] } }, "sink chest"))
end

-- Blueprint of everything the player force owns in the area, minus fixtures.
local function export(label, x1, y1, x2, y2)
  local inv = game.create_inventory(1)
  local stack = inv[1]
  stack.set_stack({ name = "blueprint" })
  local mapping = stack.create_blueprint({ surface = surface, force = "player", area = { { x1, y1 }, { x2 + 1, y2 + 1 } } })
  local keep, removed = {}, 0
  local entities = stack.get_blueprint_entities() or {}
  for _, e in ipairs(entities) do
    local real = mapping[e.entity_number]
    if real and real.valid and fixtures[real.unit_number] then removed = removed + 1 else keep[#keep + 1] = e end
  end
  stack.set_blueprint_entities(keep)
  stack.label = label
  out("BLUEPRINT %s (%d entities, %d fixtures removed): %s", label, #keep, removed, stack.export_stack())
  inv.destroy()
end

local function status_counts(list)
  local counts = {}
  for _, e in ipairs(list) do
    local name = "?"
    for k, v in pairs(defines.entity_status) do if v == e.status then name = k end end
    counts[name] = (counts[name] or 0) + 1
  end
  local parts = {}
  for k, v in pairs(counts) do parts[#parts + 1] = k .. "=" .. v end
  table.sort(parts)
  return table.concat(parts, " ")
end

---------------------------------------------------------------------------------------------
-- Design 1: smelting column fed with half a belt of ore (the author's two-belt principle).
-- Furnaces in a column; west belt = ore (inner lane) + plates (outer), east belt = raw coal
-- (inner) + ash (outer). Filtered output inserters; undergrounds at the top let only the outer
-- lanes through; plates and ash end in chests. `input_downstream` puts each input inserter on the
-- downstream (north) tile of its furnace, the output inserter on the upstream tile.
---------------------------------------------------------------------------------------------
-- `taps`: nil = raw coal from an infinite source; a number = that many Mechanical inserters taking
-- raw coal from a full, moving raw coal belt running north along x = ox + 5.
local function smelting_column(ox, oy, ore_item, plate_item, input_downstream, count, taps)
  local d = { furnaces = {}, plate_chests = {} }
  for i = 0, count - 1 do
    local y = oy + 2 * i
    d.furnaces[#d.furnaces + 1] = furnace(ox, y)
    local in_row, out_row = y, y + 1
    if not input_downstream then in_row, out_row = y + 1, y end
    inserter(ox - 1, in_row, W)                 -- ore: belt -> furnace
    inserter(ox - 1, out_row, E, plate_item)    -- plate: furnace -> belt (outer lane)
    inserter(ox + 2, in_row, E)                 -- raw coal: belt -> furnace
    inserter(ox + 2, out_row, W, "ash")         -- ash: furnace -> belt (outer lane)
  end
  local bottom = oy + 2 * count
  -- West belt: ore enters by side-loading from the east (inner lane); top passes the west lane.
  belts(ox - 2, bottom + 2, oy, N)
  underground(ox - 2, oy - 1, E, "input")
  underground(ox - 1, oy - 1, E, "output")
  belts(ox, oy - 1, oy - 3, N)
  inserter(ox - 1, oy - 2, E); d.plate_chests[1] = chest(ox - 2, oy - 2)
  inserter(ox - 1, oy - 3, E); d.plate_chests[2] = chest(ox - 2, oy - 3)
  -- East belt: raw coal enters from the west (inner lane); top passes the east lane.
  belts(ox + 3, bottom + 2, oy, N)
  underground(ox + 3, oy - 1, W, "input")
  underground(ox + 2, oy - 1, W, "output")
  belts(ox + 1, oy - 1, oy - 3, N)
  inserter(ox + 2, oy - 3, W); d.ash_chest = chest(ox + 3, oy - 3)
  -- Fixtures: half a belt of ore and raw coal.
  fixture(belt(ox - 1, bottom + 1, W))
  d.sources = { source(ox - 1, bottom + 1, W, ore_item) }
  if taps then
    -- Raw coal main belt beside the column; each tap drops onto the fuel belt's far (west, inner) lane.
    for y = bottom + 2, oy - 3, -1 do fixture(belt(ox + 5, y, N)) end
    d.sources[#d.sources + 1] = source(ox + 5, bottom + 2, N, "raw-coal")
    d.sinks = { sink(ox + 5, oy - 3, N) }
    for i = 1, taps do inserter(ox + 4, bottom + 2 - i, E) end
    d.area = { ox - 2, oy - 3, ox + 5, bottom + 2 }
  else
    fixture(belt(ox + 2, bottom, E))
    d.sources[#d.sources + 1] = source(ox + 2, bottom, E, "raw-coal")
    d.area = { ox - 2, oy - 3, ox + 3, bottom + 2 }
  end
  d.plate_item = plate_item
  d.ore_item = ore_item
  d.ore_column = { ox - 2, oy - 1, bottom + 2 }   -- west belt incl. the underground entrance
  d.fuel_column = { ox + 3, oy - 1, bottom + 2 }
  return d
end

---------------------------------------------------------------------------------------------
-- Design 2: burner mining drills on raw coal filling one belt. Four drills per side drop onto the
-- output belt; a fifth drill per side (at the south end, facing south) feeds only the service
-- belt behind its row. Service belts: fuel on the inner lane, ash (from ash-filtered inserters)
-- on the outer lane, separated at the top by undergrounds into ash chests.
---------------------------------------------------------------------------------------------
local function coal_field(ox, oy, fuel_downstream)
  local d = { drills = {}, ash_chests = {} }
  ore("raw-coal", ox - 2, oy, ox - 1, oy + 9)
  ore("raw-coal", ox + 1, oy, ox + 2, oy + 9)
  for _, side in ipairs({ { sx = -1, dx = ox - 2, ix = ox - 3, bx = ox - 4, face = E, belt_side = W, drill_side = E },
                          { sx = 1, dx = ox + 1, ix = ox + 3, bx = ox + 4, face = W, belt_side = E, drill_side = W } }) do
    for i = 0, 3 do
      local y = oy + 2 * i
      d.drills[#d.drills + 1] = drill(side.dx, y, side.face)
      local fuel_row, ash_row = y, y + 1
      if not fuel_downstream then fuel_row, ash_row = y + 1, y end
      inserter(side.ix, fuel_row, side.belt_side)          -- raw coal: service belt -> drill
      inserter(side.ix, ash_row, side.drill_side, "ash")   -- ash: drill -> service belt (outer lane)
    end
    -- Fuel drill: faces south, its coal runs along row oy+10 into the service belt's side.
    local fd = drill(side.dx, oy + 8, S)
    d.drills[#d.drills + 1] = fd
    fd.get_fuel_inventory().insert({ name = "raw-coal", count = 5 })
    local drop_x = math.floor(fd.drop_position.x)
    if math.floor(fd.drop_position.y) ~= oy + 10 then out("fuel drill drops at unexpected row %d", math.floor(fd.drop_position.y)) end
    local step = side.sx
    for x = drop_x, side.bx - step, step do belt(x, oy + 10, step < 0 and W or E) end
    inserter(side.ix, oy + 9, side.belt_side)              -- fuel drill's own fuel, downstream of the side-load
    inserter(side.ix, oy + 8, side.drill_side, "ash")
    -- Service belt and the ash separator at the top.
    belts(side.bx, oy + 11, oy, N)
    local tunnel = side.sx < 0 and E or W                  -- west belt passes W lane, east belt passes E lane
    underground(side.bx, oy - 1, tunnel, "input")
    underground(side.bx - step, oy - 1, tunnel, "output")
    belts(side.bx - 2 * step, oy - 1, oy - 3, N)
    inserter(side.bx - step, oy - 3, side.sx < 0 and E or W)
    d.ash_chests[#d.ash_chests + 1] = chest(side.bx, oy - 3)
  end
  belts(ox, oy + 7, oy - 3, N)
  d.sinks = { sink(ox, oy - 3, N) }
  d.chests = d.ash_chests
  d.area = { ox - 4, oy - 3, ox + 4, oy + 11 }
  return d
end

---------------------------------------------------------------------------------------------
-- A structure copied out of a save or a blueprint by tools/extract-design.js, rebuilt at (ox, oy)
-- on Raw coal.
-- Every drill gets 5 Raw coal to start; every belt end with nothing after it gets a counting sink.
---------------------------------------------------------------------------------------------
local extracted = require("extracted")

local function from_save(key, ox, oy)
  local spec = extracted[key]
  local d = { drills = {}, chests = {}, sinks = {} }
  for _, e in ipairs(spec.entities) do
    if e.name == "burner-mining-drill" then ore("raw-coal", ox + math.floor(e.x) - 1, oy + math.floor(e.y) - 1, ox + math.floor(e.x), oy + math.floor(e.y)) end
  end
  local belts_built = {}
  for _, e in ipairs(spec.entities) do
    local built = place({ name = e.name, position = { ox + e.x, oy + e.y }, direction = e.dir and defines.direction[e.dir] or nil, type = e.ug })
    if built then
      if e.filter then built.use_filters = true; built.set_filter(1, e.filter) end
      if e.mode then built.inserter_filter_mode = e.mode end
      if built.type == "mining-drill" then
        d.drills[#d.drills + 1] = built
        built.get_fuel_inventory().insert({ name = "raw-coal", count = 5 })
      elseif built.type == "container" then
        d.chests[#d.chests + 1] = built
      elseif built.type == "transport-belt" then
        belts_built[#belts_built + 1] = built
      end
    end
  end
  for _, b in ipairs(belts_built) do
    local v = VEC[b.direction]
    local nx, ny = math.floor(b.position.x) + v[1], math.floor(b.position.y) + v[2]
    local next_belt = surface.find_entities_filtered({ area = { { nx + 0.1, ny + 0.1 }, { nx + 0.9, ny + 0.9 } },
      type = { "transport-belt", "underground-belt", "splitter", "loader" } })
    if #next_belt == 0 then d.sinks[#d.sinks + 1] = sink(math.floor(b.position.x), math.floor(b.position.y), b.direction) end
  end
  d.area = { ox, oy, ox + spec.width - 1, oy + spec.height - 1 }
  d.size = spec.width .. "x" .. spec.height
  return d
end

---------------------------------------------------------------------------------------------
-- A horizontal smelting column from blueprints/ (blueprints/smelting-column.txt, the author's
-- design, copied with extract-design.js --blueprint): ore belt along the top, fuel belt along the
-- bottom, both flowing east. Fixtures side-load ore onto the top belt's lane next to the furnaces
-- and Raw coal onto the bottom belt's lane next to the furnaces, half a belt each. Chests above the
-- furnaces collect plates, chests below them Ash.
---------------------------------------------------------------------------------------------
local function column_from_blueprint(key, ox, oy, ore_item, plate_item)
  local spec = extracted[key]
  local d = { furnaces = {}, plate_chests = {}, ash_chests = {} }
  for _, e in ipairs(spec.entities) do
    local built = place({ name = e.name, position = { ox + e.x, oy + e.y }, direction = e.dir and defines.direction[e.dir] or nil, type = e.ug })
    if built then
      if e.filter then built.use_filters = true; built.set_filter(1, e.filter) end
      if e.mode then built.inserter_filter_mode = e.mode end
      if built.type == "furnace" then
        d.furnaces[#d.furnaces + 1] = built
      elseif built.type == "container" then
        local list = e.y < spec.height / 2 and d.plate_chests or d.ash_chests
        list[#list + 1] = built
      end
    end
  end
  local bottom = oy + spec.height - 1
  for x = ox - 3, ox - 1 do fixture(belt(x, oy, E)); fixture(belt(x, bottom, E)) end
  fixture(belt(ox - 2, oy + 1, N))
  fixture(belt(ox - 1, bottom - 1, S))
  d.sources = { source(ox - 2, oy + 1, N, ore_item), source(ox - 1, bottom - 1, S, "raw-coal") }
  d.plate_item, d.ore_item = plate_item, ore_item
  d.area = { ox, oy, ox + spec.width - 1, bottom }
  d.belt_area = d.area
  return d
end

---------------------------------------------------------------------------------------------
-- Tap throughput: one Mechanical inserter moving raw coal from a full belt onto another belt.
-- `moving`: the source belt flows into a sink (items pass the inserter) or backs up (stands still).
---------------------------------------------------------------------------------------------
local function tap_rate(ox, oy, moving)
  local d = { chests = {} }
  belts(ox, oy + 10, oy, N)
  source(ox, oy + 10, N, "raw-coal")
  d.sinks = {}
  if moving then d.sinks[1] = sink(ox, oy, N) end
  inserter(ox + 1, oy + 5, W)
  belts(ox + 2, oy + 5, oy + 5, E)
  belt(ox + 3, oy + 5, E)
  d.tapped = sink(ox + 3, oy + 5, E)
  d.area = { ox, oy, ox + 3, oy + 10 }
  return d
end

---------------------------------------------------------------------------------------------

local function count_items(c, item)
  if not c then return 0, 0 end
  local wanted, other = 0, 0
  for _, stack in pairs(c.get_inventory(defines.inventory.chest).get_contents()) do
    if stack.name == item then wanted = wanted + stack.count else other = other + stack.count end
  end
  return wanted, other
end

script.on_load(function() surface = game and game.surfaces.nauvis end)

script.on_init(function()
  -- A graphical run creates the local player, and freeplay would then drop its crash site onto
  -- the designs near the origin and play the landing cutscene, which holds the game until Tab.
  if remote.interfaces["freeplay"] then
    remote.call("freeplay", "set_disable_crashsite", true)
    remote.call("freeplay", "set_skip_intro", true)
  end
  surface = game.surfaces.nauvis
  surface.request_to_generate_chunks({ 0, 0 }, 4)
  surface.force_generate_chunk_requests()
  for _, e in pairs(surface.find_entities({ { -120, -120 }, { 120, 120 } })) do if e.valid then e.destroy() end end
  local tiles = {}
  for x = -120, 119 do for y = -120, 119 do tiles[#tiles + 1] = { name = "grass-1", position = { x, y } } end end
  surface.set_tiles(tiles)

  -- Earlier runs (results in the tutorial): coal_field(0, -10, true/false), input-upstream and
  -- input-downstream vertical columns (smelting_column without taps),
  -- from_save("user-loop", ...), from_save("user-module", ...) (the module as cut from the save,
  -- with 8 tiles of the save's trunk belt). `shot` = screenshot key and zoom, taken when rendering
  -- is available.
  storage.designs = {
    { label = "smelting column (author's blueprint) on iron", kind = "smelt", shot = { "smelting-column", 1.5 },
      d = column_from_blueprint("smelting-column", 0, 30, "iron-ore", "iron-plate") },
    { label = "smelting column (author's blueprint) on copper", kind = "smelt",
      d = column_from_blueprint("smelting-column", 0, 45, "copper-ore", "copper-plate") },
    { label = "copper column fuelled by 1 tap", kind = "smelt",
      d = smelting_column(-20, -10, "copper-ore", "copper-plate", true, 10, 1) },
    { label = "raw coal module (author's design)", kind = "coal", shot = { "raw-coal-module", 2 },
      d = from_save("raw-coal-module", -100, 40) }, -- from blueprints/raw-coal-module.txt
    { label = "tap from a moving full belt", kind = "tap", d = tap_rate(20, -10, true) },
    { label = "tap from a standing full belt", kind = "tap", d = tap_rate(30, -10, false) },
  }
  storage.fixtures = fixtures
  for _, x in ipairs(storage.designs) do
    x.totals, x.warm = {}, {}
    local a = x.d.area
    export(x.label, a[1], a[2], a[3], a[4])
  end
end)

local function snapshot(x)
  local d = x.d
  if x.kind == "tap" then
    return { tapped = x.totals.tapped or 0 }
  elseif x.kind == "smelt" then
    local plates, wrong = 0, 0
    for _, c in ipairs(d.plate_chests) do
      local p, o = count_items(c, d.plate_item)
      plates, wrong = plates + p, wrong + o
    end
    local ash = 0
    for _, c in ipairs(d.ash_chests or { d.ash_chest }) do
      local a, o = count_items(c, "ash")
      ash, wrong = ash + a, wrong + o
    end
    return { plates = plates, ash = ash, wrong = wrong }
  else
    -- Raw coal and ash leaving through sinks, plus ash collected in the design's own chests.
    local ash, wrong = x.totals.ash or 0, 0
    for _, c in ipairs(d.chests) do
      local a, o = count_items(c, "ash")
      ash, wrong = ash + a, wrong + o
    end
    return { coal = x.totals["raw-coal"] or 0, ash = ash, wrong = wrong }
  end
end

script.on_event(defines.events.on_tick, function(event)
  if not storage.designs then return end
  surface = surface or game.surfaces.nauvis
  -- Empty the sinks every second so they never fill; keep running totals per item.
  if event.tick % 60 == 0 then
    for _, x in ipairs(storage.designs) do
      if x.d.tapped and x.d.tapped.valid then
        x.totals.tapped = (x.totals.tapped or 0) + x.d.tapped.get_item_count()
        x.d.tapped.clear_items_inside()
      end
      for _, s in ipairs(x.d.sinks or {}) do
        if s.valid then
          for _, stack in pairs(s.get_inventory(defines.inventory.chest).get_contents()) do
            x.totals[stack.name] = (x.totals[stack.name] or 0) + stack.count
          end
          s.clear_items_inside()
        end
      end
    end
  end
  if event.tick == T_WARM then
    for _, x in ipairs(storage.designs) do
      x.warm = snapshot(x)
      -- Screenshot (no-op when headless) with entity info, like holding Alt in game.
      if x.shot then
        local a = x.d.area
        local key, zoom = x.shot[1], x.shot[2]
        local w, h = a[3] - a[1] + 3, a[4] - a[2] + 3
        out("screenshot %s at tick %d", key, event.tick)
        -- With entity info (alt view), like every picture in the tutorial.
        game.take_screenshot({
          allow_in_replay = true, -- benchmark runs count as replays
          surface = surface, position = { (a[1] + a[3] + 1) / 2, (a[2] + a[4] + 1) / 2 },
          resolution = { math.floor(w * 32 * zoom), math.floor(h * 32 * zoom) }, zoom = zoom,
          path = "cellforge/shots/" .. key .. ".jpg",
          show_entity_info = true, daytime = 0, hide_clouds = true, hide_fog = true,
          force_render = true, anti_alias = true, quality = 90,
        })
      end
    end
  elseif event.tick == T_END then
    local sec = (T_END - T_WARM) / 60
    for _, x in ipairs(storage.designs) do
      local now = snapshot(x)
      if x.kind == "tap" then
        out("%s: %.3f items/s", x.label, (now.tapped - x.warm.tapped) / sec)
      elseif x.kind == "smelt" then
        out("%s: plates %.3f/s, ash %.3f/s, wrong items %d; furnaces: %s", x.label,
          (now.plates - x.warm.plates) / sec, (now.ash - x.warm.ash) / sec, now.wrong, status_counts(x.d.furnaces))
      else
        out("%s: raw coal out %.2f/s, ash %.3f/s, wrong items %d, sinks %d; drills (%d): %s", x.label,
          (now.coal - x.warm.coal) / sec, (now.ash - x.warm.ash) / sec, now.wrong, #x.d.sinks, #x.d.drills,
          status_counts(x.d.drills))
      end
      -- Cut the supply to the smelting columns and let them run dry.
      if x.kind == "smelt" then
        for _, loader in ipairs(x.d.sources) do if loader.valid then loader.destroy() end end
      end
    end
  elseif event.tick == T_DRAIN then
    for _, x in ipairs(storage.designs) do
      if x.kind == "smelt" then
        local ore_left, coal_left
        if x.d.belt_area then
          local a = x.d.belt_area
          ore_left = on_area(a[1], a[2], a[3], a[4], x.d.ore_item)
          coal_left = on_area(a[1], a[2], a[3], a[4], "raw-coal")
        else
          local o, f = x.d.ore_column, x.d.fuel_column
          ore_left, coal_left = on_belts(o[1], o[2], o[3], x.d.ore_item), on_belts(f[1], f[2], f[3], "raw-coal")
        end
        out("%s, %d s after supply stopped: %d ore and %d raw coal left on the belts; furnaces: %s", x.label,
          (T_DRAIN - T_END) / 60, ore_left, coal_left, status_counts(x.d.furnaces))
      end
    end
    out("DONE")
    storage.designs = nil
  end
end)
