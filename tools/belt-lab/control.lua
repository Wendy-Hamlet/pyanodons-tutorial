-- Belt mechanics the smelting and mining designs rely on. Results are CF-BELT log lines.
--   1. Side-loading into an underground belt: which lane of the incoming belt gets through,
--      for entrances and exits facing east or west.
--   2. Which lane a burner mining drill drops onto (drill west / east of a north-going belt).
--   3. Which lane an inserter drops onto.
--   4. Mechanical inserter throughput from a full belt into a chest.
-- Lanes are named by compass side of a north-going belt: W (left, line 1) and E (right, line 2).

local N, E, S, W = defines.direction.north, defines.direction.east, defines.direction.south, defines.direction.west
local T = 3600

local function out(fmt, ...) log("CF-BELT " .. string.format(fmt, ...)) end

local function belt(surface, x, y, dir)
  return surface.create_entity({ name = "transport-belt", position = { x + 0.5, y + 0.5 }, direction = dir, force = "player" })
end

local VEC = { [N] = { 0, -1 }, [E] = { 1, 0 }, [S] = { 0, 1 }, [W] = { -1, 0 } }

local function must(entity, what)
  if not entity then out("FIXTURE FAILED: %s", what) end
  return entity
end

-- Infinity chest + loader feeding `item` into the belt tile (x, y), which flows in `dir`.
-- The loader occupies the two tiles behind that belt tile, the chest the tile behind the loader.
local function source(surface, x, y, dir, item)
  local v = VEC[dir]
  local loader = must(surface.create_entity({ name = "loader", position = { x + 0.5 - 1.5 * v[1], y + 0.5 - 1.5 * v[2] }, direction = dir, type = "output", force = "player" }), "source loader")
  local chest = must(surface.create_entity({ name = "infinity-chest", position = { x + 0.5 - 3 * v[1], y + 0.5 - 3 * v[2] }, force = "player" }), "source chest")
  if chest then chest.set_infinity_container_filter(1, { name = item, count = 50, mode = "exactly" }) end
  return loader, chest
end

-- Loader taking everything arriving on the belt tile (x, y), which flows in `dir`, into a chest.
local function sink(surface, x, y, dir)
  local v = VEC[dir]
  must(surface.create_entity({ name = "loader", position = { x + 0.5 + 1.5 * v[1], y + 0.5 + 1.5 * v[2] }, direction = dir, type = "input", force = "player" }), "sink loader")
  return must(surface.create_entity({ name = "iron-chest", position = { x + 0.5 + 3 * v[1], y + 0.5 + 3 * v[2] }, force = "player" }), "sink chest")
end

local function lanes(b)
  local function list(line)
    local parts = {}
    for _, c in pairs(b.get_transport_line(line).get_contents()) do parts[#parts + 1] = c.name .. "x" .. c.count end
    return table.concat(parts, ",")
  end
  return "W[" .. list(1) .. "] E[" .. list(2) .. "]"
end

script.on_init(function()
  local surface = game.surfaces.nauvis
  surface.request_to_generate_chunks({ 0, 0 }, 4)
  surface.force_generate_chunk_requests()
  for _, e in pairs(surface.find_entities({ { -120, -120 }, { 120, 120 } })) do if e.valid then e.destroy() end end
  local tiles = {}
  for x = -120, 119 do for y = -120, 119 do tiles[#tiles + 1] = { name = "lab-dark-1", position = { x, y } } end end
  surface.set_tiles(tiles)
  local s = { cases = {} }
  storage.s = s

  -- 1. Two-lane belt (iron ore on W, copper ore on E) side-loading into an underground belt.
  local variants = {
    { label = "entrance facing east", kind = "input", dir = E },
    { label = "entrance facing west", kind = "input", dir = W },
    { label = "exit facing east", kind = "output", dir = E },
    { label = "exit facing west", kind = "output", dir = W },
  }
  for i, v in ipairs(variants) do
    local x = -60 + i * 20
    -- Belt going north from y=10 to y=1; lanes fed by side-loading at y=10.
    for y = 1, 10 do belt(surface, x, y, N) end
    belt(surface, x - 1, 10, E); source(surface, x - 1, 10, E, "iron-ore")    -- W lane
    belt(surface, x + 1, 10, W); source(surface, x + 1, 10, W, "copper-ore")  -- E lane
    -- Underground pair at y=0; the north-going belt side-loads into the tile at x.
    local step = v.dir == E and 1 or -1
    local ug_in, ug_out
    if v.kind == "input" then
      ug_in = surface.create_entity({ name = "underground-belt", position = { x + 0.5, 0.5 }, direction = v.dir, type = "input", force = "player" })
      ug_out = surface.create_entity({ name = "underground-belt", position = { x + 0.5 + 3 * step, 0.5 }, direction = v.dir, type = "output", force = "player" })
      belt(surface, x + 4 * step, 0, v.dir)
      s.cases[#s.cases + 1] = { label = v.label, chest = sink(surface, x + 4 * step, 0, v.dir) }
    else
      -- Side-loading into the back of an exit: the exit's own input comes from an entrance behind it.
      ug_in = surface.create_entity({ name = "underground-belt", position = { x + 0.5 - 3 * step, 0.5 }, direction = v.dir, type = "input", force = "player" })
      ug_out = surface.create_entity({ name = "underground-belt", position = { x + 0.5, 0.5 }, direction = v.dir, type = "output", force = "player" })
      belt(surface, x + step, 0, v.dir)
      s.cases[#s.cases + 1] = { label = v.label, chest = sink(surface, x + step, 0, v.dir) }
    end
  end

  -- 2. Burner mining drills on iron ore beside a north-going belt, one on each side.
  for _, side in ipairs({ { label = "drill west of belt, facing east", dx = -1.5, dir = E, x = 40 }, { label = "drill east of belt, facing west", dx = 1.5, dir = W, x = 50 } }) do
    for ty = 9, 10 do for tx = side.x + (side.dx < 0 and -2 or 1), side.x + (side.dx < 0 and -1 or 2) do
      surface.create_entity({ name = "iron-ore", position = { tx + 0.5, ty + 0.5 }, amount = 100000 })
    end end
    local d = surface.create_entity({ name = "burner-mining-drill", position = { side.x + 0.5 + side.dx, 10 }, direction = side.dir, force = "player" })
    d.get_fuel_inventory().insert({ name = "raw-coal", count = 50 })
    for y = 0, 10 do belt(surface, side.x, y, N) end
    s.cases[#s.cases + 1] = { label = side.label, belt = surface.find_entity("transport-belt", { side.x + 0.5, 3.5 }) }
  end

  -- 3. Inserter from a chest onto a north-going belt, from the west side.
  for y = 20, 30 do belt(surface, 0, y, N) end
  local ins = surface.create_entity({ name = "burner-inserter", position = { -0.5, 29.5 }, direction = E, force = "player" })
  if ins.drop_position.x < -0.5 then ins.direction = W end
  local c = surface.create_entity({ name = "iron-chest", position = { ins.pickup_position.x, ins.pickup_position.y }, force = "player" })
  c.insert({ name = "iron-plate", count = 100 })
  s.cases[#s.cases + 1] = { label = "inserter west of belt dropping plates", belt = surface.find_entity("transport-belt", { 0.5, 22.5 }) }

  -- 4. Mechanical inserter from a full belt into a chest.
  for y = 40, 50 do belt(surface, 20, y, N) end
  source(surface, 20, 50, N, "iron-plate")
  local taker = surface.create_entity({ name = "burner-inserter", position = { 21.5, 45.5 }, direction = W, force = "player" })
  if taker.pickup_position.x > 21.5 then taker.direction = E end
  s.taker_chest = surface.create_entity({ name = "iron-chest", position = { taker.drop_position.x, taker.drop_position.y }, force = "player" })
end)

script.on_event(defines.events.on_tick, function(event)
  local s = storage.s
  if not s or event.tick ~= T then return end
  for _, c in ipairs(s.cases) do
    if c.chest then
      out("underground %s: passed iron ore (W lane) %d, copper ore (E lane) %d", c.label,
        c.chest.get_item_count("iron-ore"), c.chest.get_item_count("copper-ore"))
    else
      out("%s: %s", c.label, lanes(c.belt))
    end
  end
  out("mechanical inserter belt -> chest: %.2f items/s", s.taker_chest.get_item_count("iron-plate") / (T / 60))
  out("DONE")
end)
