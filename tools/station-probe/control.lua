-- Measures which platform tiles an inserter can serve, per wagon, for different compositions
-- stopping at the same train stop. Every tile beside the platform gets an inserter + chest; after
-- the trains arrive, each inserter's drop target tells which carriage it reaches.

local TESTS = {
  { label = "1+2 cargo-wagon (7 tiles)", stock = { "locomotive", "cargo-wagon", "cargo-wagon" } },
  { label = "1+4 mk02-wagon (3.5 tiles)", stock = { "locomotive", "mk02-wagon", "mk02-wagon", "mk02-wagon", "mk02-wagon" } },
}
local STOP_X = 101   -- train stop x; trains run east (+x) and stop here
local SPAN = 26      -- platform tiles inspected behind the stop

local function gap(a, b)
  local pa, pb = prototypes.entity[a], prototypes.entity[b]
  return (pa.joint_distance + pb.joint_distance) / 2 + (pa.connection_distance + pb.connection_distance) / 2
end

local function place_loader(surface, x, y, track_y)
  local inserter = surface.create_entity({ name = "burner-inserter", position = { x + 0.5, y + 0.5 }, direction = defines.direction.north, force = "player" })
  if not inserter then return nil end
  if (inserter.drop_position.y - (y + 0.5)) * (track_y - (y + 0.5)) < 0 then
    inserter.direction = defines.direction.south
  end
  -- Py gives burner inserters a void energy source: no fuel needed.
  local chest_y = y + ((y + 0.5) < track_y and -1 or 1)
  local chest = surface.create_entity({ name = "wooden-chest", position = { x + 0.5, chest_y + 0.5 }, force = "player" })
  chest.insert({ name = "iron-plate", count = 50 })
  return { inserter = inserter, chest = chest, x = x, side = (y + 0.5) < track_y and "N" or "S" }
end

script.on_init(function()
  local surface = game.surfaces.nauvis
  surface.request_to_generate_chunks({ 64, 16 }, 3)
  surface.force_generate_chunk_requests()
  local area = { { -8, -8 }, { 140, 40 } }
  for _, e in pairs(surface.find_entities(area)) do if e.valid then e.destroy() end end
  local tiles = {}
  for x = -8, 139 do for y = -8, 39 do tiles[#tiles + 1] = { name = "lab-dark-1", position = { x, y } } end end
  surface.set_tiles(tiles)

  storage.runs = {}
  for i, t in ipairs(TESTS) do
    local y = (i - 1) * 16 + 4           -- rail tiles y .. y+1, center line y+1
    for x = 1, 131, 2 do
      surface.create_entity({ name = "straight-rail", position = { x, y + 1 }, direction = defines.direction.east, force = "player" })
    end
    local stop
    for _, dy in ipairs({ 2, -2 }) do
      for _, dir in ipairs({ defines.direction.east, defines.direction.west }) do
        if not stop and surface.can_place_entity({ name = "train-stop", position = { STOP_X, y + 1 + dy }, direction = dir, force = "player" }) then
          local s = surface.create_entity({ name = "train-stop", position = { STOP_X, y + 1 + dy }, direction = dir, force = "player" })
          if s.connected_rail and dir == defines.direction.east then stop = s else s.destroy() end
        end
      end
    end
    stop.backer_name = "probe-" .. i
    local loaders = {}
    for x = STOP_X - SPAN, STOP_X + 2 do
      for _, row in ipairs({ y - 1, y + 2 }) do
        local l = place_loader(surface, x, row, y + 1)
        if l then loaders[#loaders + 1] = l end
      end
    end
    local x, carriages = 20, {}
    for k, name in ipairs(t.stock) do
      if k > 1 then x = x - gap(t.stock[k - 1], name) end
      local c = surface.create_entity({ name = name, position = { x, y + 1 }, direction = defines.direction.east, force = "player" })
      if c.type == "locomotive" then c.get_fuel_inventory().insert({ name = "coal", count = 20 }) end
      carriages[#carriages + 1] = c
    end
    local train = carriages[1].train
    local schedule = train.get_schedule()
    schedule.add_record({ station = stop.backer_name, wait_conditions = { { type = "time", ticks = 100000 } } })
    schedule.go_to_station(1)
    train.manual_mode = false
    storage.runs[i] = { label = t.label, train = train, stop = stop, loaders = loaders }
  end
end)

script.on_event(defines.events.on_tick, function(event)
  if event.tick ~= 3000 or not storage.runs then return end
  for _, r in ipairs(storage.runs) do
    local index = {}
    for k, c in ipairs(r.train.carriages) do index[c.unit_number] = k end
    local parts = {}
    for k, c in ipairs(r.train.carriages) do
      parts[#parts + 1] = string.format("%s@%.2f", c.name, c.position.x - r.stop.position.x)
    end
    log(string.format("CF-STATION %s | state %s | carriages %s", r.label, tostring(r.train.state), table.concat(parts, " ")))
    for _, side in ipairs({ "N", "S" }) do
      local row, moved = {}, 0
      for x = STOP_X - SPAN, STOP_X + 2 do row[x] = "#" end
      for _, l in ipairs(r.loaders) do
        if l.side == side then
          local target = l.inserter.drop_target
          local k = target and index[target.unit_number]
          local delivered = l.chest.get_item_count("iron-plate") < 50
          row[l.x] = k and (k == 1 and "L" or tostring(k - 1)) or "."
          if delivered then moved = moved + 1 end
          if delivered ~= (k ~= nil and k > 1) then row[l.x] = "?" end
        end
      end
      local s = {}
      for x = STOP_X - SPAN, STOP_X + 2 do s[#s + 1] = row[x] end
      log(string.format("CF-STATION %s | side %s | x %d..%d | %s | %d inserters delivered", r.label, side, -SPAN, 2, table.concat(s), moved))
    end
  end
end)
