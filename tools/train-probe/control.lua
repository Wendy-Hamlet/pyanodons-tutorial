-- Throwaway measurement: train top speed, acceleration and braking distance per composition.
local LENGTH = 10000
local TESTS = {
  { label = "locomotive+2 cargo, coal",          loco = "locomotive",      wagon = "cargo-wagon",      n = 2, fuel = "coal" },
  { label = "locomotive+4 cargo, coal",          loco = "locomotive",      wagon = "cargo-wagon",      n = 4, fuel = "coal" },
  { label = "2 locomotive+4 cargo, coal",        loco = "locomotive",      wagon = "cargo-wagon",      n = 4, fuel = "coal", locos = 2 },
  { label = "locomotive+2 cargo, nuclear-fuel",  loco = "locomotive",      wagon = "cargo-wagon",      n = 2, fuel = "nuclear-fuel" },
  { label = "mk02+4 mk02-wagon, diesel-canister",loco = "mk02-locomotive", wagon = "mk02-wagon",       n = 4, fuel = "diesel-canister" },
  { label = "ht+2 ht-wagon, nexelit-battery",    loco = "ht-locomotive",   wagon = "ht-generic-wagon", n = 2, fuel = "nexelit-battery" },
  { label = "mk04+4 mk04-wagon, quantum-battery",loco = "mk04-locomotive", wagon = "mk04-wagon",       n = 4, fuel = "quantum-battery" },
}

local function gap(a, b)
  local pa, pb = prototypes.entity[a], prototypes.entity[b]
  return (pa.joint_distance + pb.joint_distance) / 2 + (pa.connection_distance + pb.connection_distance) / 2
end

script.on_init(function()
  local surface = game.surfaces.nauvis
  local rows = #TESTS * 8 + 8
  for x = -64, LENGTH + 64, 32 do for y = -16, rows, 32 do surface.request_to_generate_chunks({ x, y }, 0) end end
  surface.force_generate_chunk_requests()
  local area = { { -64, -16 }, { LENGTH + 64, rows } }
  for _, e in pairs(surface.find_entities(area)) do if e.valid then e.destroy() end end
  local tiles = {}
  for x = -64, LENGTH + 64 do for y = -8, rows - 1 do tiles[#tiles + 1] = { name = "lab-dark-1", position = { x, y } } end end
  surface.set_tiles(tiles)

  storage.runs = {}
  for i, t in ipairs(TESTS) do
    local y = i * 8
    local last
    for x = 1, LENGTH, 2 do
      last = surface.create_entity({ name = "straight-rail", position = { x, y + 1 }, direction = defines.direction.east, force = "player" })
    end
    local stock = {}
    for _ = 1, t.locos or 1 do stock[#stock + 1] = t.loco end
    for _ = 1, t.n do stock[#stock + 1] = t.wagon end
    local x, carriages = 60, {}
    for k, name in ipairs(stock) do
      if k > 1 then x = x - gap(stock[k - 1], name) end
      local c = surface.create_entity({ name = name, position = { x, y + 1 }, direction = defines.direction.east, force = "player" })
      carriages[#carriages + 1] = c
      if c and c.type == "locomotive" then c.get_fuel_inventory().insert({ name = t.fuel, count = 50 }) end
    end
    local train = carriages[1] and carriages[1].train
    if train then
      local schedule = train.get_schedule()
      schedule.add_record({ rail = last, temporary = true })
      schedule.go_to_station(1)
      train.manual_mode = false
      storage.runs[i] = { train = train, label = t.label, start_x = carriages[1].position.x, max = 0, prev = 0,
        carriages = #train.carriages, expected = #stock, weight = train.weight }
    else
      log("CF-PROBE " .. t.label .. " : could not build train")
    end
  end
end)

script.on_event(defines.events.on_tick, function(event)
  if not storage.runs then return end
  for i, r in pairs(storage.runs) do
    if r.train.valid and not r.done then
      local v = r.train.speed * 216 -- km/h
      local x = r.train.front_stock.position.x
      if v > r.max then r.max = v end
      if not r.brake_x and v < r.prev - 1e-6 and v > 0.5 * r.max then r.brake_x = x; r.brake_v = r.prev end
      if r.brake_x and v < 0.01 then
        r.done = true
        log(string.format("CF-PROBE %s | cars %d/%d weight %.0f | top %.0f km/h | braking %.0f tiles from %.0f km/h | stop tick %d",
          r.label, r.carriages, r.expected, r.weight, r.max, x - r.brake_x, r.brake_v, event.tick))
      end
      r.prev = v
    end
  end
  if event.tick % 600 == 0 then
    local parts = {}
    for _, r in pairs(storage.runs) do if r.train.valid then parts[#parts + 1] = string.format("%.0f", r.train.speed * 216) end end
    log("CF-PROBE t=" .. event.tick / 60 .. "s speeds " .. table.concat(parts, " "))
  end
end)
