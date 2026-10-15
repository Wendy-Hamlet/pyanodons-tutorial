-- Belt mechanics the smelting and mining designs rely on. Results are CF-BELT log lines.
--   1. Side-loading into an underground belt: which lane of the incoming belt gets through,
--      for entrances and exits facing east or west.
--   2. Which lane a burner mining drill drops onto (drill west / east of a north-going belt).
--   3. Which lane an inserter drops onto.
--   4. Mechanical inserter throughput from a full belt into a chest.
--   5. Which lanes a Splitter's outputs carry when its input has items on one lane only.
--   6. The author's lane balancer: a Splitter whose two outputs side-load one belt from both sides.
--   7. A Splitter with a belt on one output only: how many items wait on the other output, with
--      and without output priority on the side that has the belt, and with the author's filter: the
--      Deconstruction planner (an item that never comes) sent to the side without a belt.
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

  -- 5. Splitter: a north-going belt fed on its E lane only, into a Splitter; both outputs run
  --    north 20 tiles. 6. The author's lane balancer: the same Splitter, then its two outputs
  --    side-loaded into one belt from opposite sides (west output from the west, east from the east).
  local function feed_e_lane(x)
    -- A belt tile behind the fed one keeps it straight, so the side feed lands on the E lane only
    -- (with nothing behind it the fed tile turns into a curve and carries both lanes).
    for y = 61, 71 do belt(surface, x, y, N) end
    belt(surface, x + 1, 70, W); source(surface, x + 1, 70, W, "iron-ore")
    must(surface.create_entity({ name = "splitter", position = { x + 1, 60.5 }, direction = N, force = "player" }), "splitter")
  end
  local function column(x, y1, y2)
    local list = {}
    for y = y1, y2 do list[#list + 1] = belt(surface, x, y, N) end
    return list
  end
  feed_e_lane(-60)
  s.split = { west = column(-60, 40, 59), east = column(-59, 40, 59) }
  feed_e_lane(60)
  -- West output: north to y 55, then east into the merged belt's west side.
  for y = 56, 59 do belt(surface, 60, y, N) end
  for x = 60, 63 do belt(surface, x, 55, E) end
  -- East output: east along y 58 to x 65, north to y 56, then west into the merged belt's east side.
  belt(surface, 61, 59, N)
  for x = 61, 64 do belt(surface, x, 58, E) end
  for y = 56, 58 do belt(surface, 65, y, N) end
  belt(surface, 65, 55, W)
  s.merged = column(64, 25, 55)

  -- 7. A belt fed on both lanes into a Splitter whose west output has a belt and whose east output
  --    has none; the second copy gives the west output priority, the third filters the
  --    Deconstruction planner to the east output. The belt ends in a sink; in the fourth and fifth
  --    copies (priority, filter) it just ends, so the west output backs up.
  s.one_out = {}
  for i, priority in ipairs({ "none", "left", "right", "left", "right" }) do
    local x = -30 + 20 * i
    for y = 61, 72 do belt(surface, x, y, N) end
    belt(surface, x - 1, 70, E); source(surface, x - 1, 70, E, "iron-plate")
    belt(surface, x + 1, 71, W); source(surface, x + 1, 71, W, "copper-plate")
    local sp = must(surface.create_entity({ name = "splitter", position = { x + 1, 60.5 }, direction = N, force = "player" }), "splitter")
    sp.splitter_output_priority = priority
    if priority == "right" then sp.splitter_filter = { name = "deconstruction-planner" } end
    for y = 50, 59 do belt(surface, x, y, N) end
    local chest = i <= 3 and sink(surface, x, 50, N) or nil
    s.one_out[i] = { priority = (priority == "right" and "right, filter Deconstruction planner" or priority)
      .. (chest and "" or ", output belt blocked"), splitter = sp, chest = chest }
  end
end)

local T5 = 1200 -- the lane counts are read after 20 s, before any output belt backs up

local function lane_sum(belts)
  local w, e = 0, 0
  for _, b in ipairs(belts) do
    w = w + b.get_transport_line(1).get_item_count()
    e = e + b.get_transport_line(2).get_item_count()
  end
  return w, e
end

script.on_event(defines.events.on_tick, function(event)
  local s = storage.s
  if s and event.tick == T5 then
    local ww, we = lane_sum(s.split.west)
    local ew, ee = lane_sum(s.split.east)
    out("splitter fed on the E lane only, after %d s: west output W %d E %d; east output W %d E %d", T5 / 60, ww, we, ew, ee)
    local mw, me = lane_sum(s.merged)
    out("splitter + two-sided merge, fed on the E lane only, after %d s: merged belt W %d E %d", T5 / 60, mw, me)
  end
  if s and event.tick == T then
    for _, c in ipairs(s.one_out) do
      local held, lines = 0, {}
      for line = 1, c.splitter.get_max_transport_line_index() do
        local n = c.splitter.get_transport_line(line).get_item_count()
        held, lines[#lines + 1] = held + n, line .. ":" .. n
      end
      out("splitter with a belt on the west output only, priority %s, after %d s: %d items on the splitter (by line %s), %d passed",
        c.priority, T / 60, held, table.concat(lines, " "), c.chest and c.chest.get_item_count() or 0)
    end
  end
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
