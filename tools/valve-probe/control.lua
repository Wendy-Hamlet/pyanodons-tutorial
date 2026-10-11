-- Does Py's Check valve (py-check-valve) do what a Pump does? Both split a pipeline into two fluid
-- segments; the Pump uses power and is 1x2, the valve is passive and 1x1. Two tests:
--
-- 1. Throughput of long steam lines of Pipes to ground at their full reach (Py's pipes have a
--    max_pipeline_extent of 320 tiles): straight lines of 55 to 625 tiles, with a Pump or a valve
--    part way, and an L of 200 + 200 tiles. An infinity pipe keeps the start full; at the end a
--    check valve passes the steam into one pipe whose segment is emptied every tick, which counts
--    what arrives.
-- 2. Pushing into a fuller segment: two 100-tile segments joined by a Pump, a valve or a plain
--    pipe, one filled to 20 % and the other to 80 %; after 40 s, where is the steam?
--
-- Results are CF-VALVE log lines.

local E = defines.direction.east
local W = defines.direction.west
local WARM, MEASURE = 600, 1800

local function out(fmt, ...) log("CF-VALVE " .. string.format(fmt, ...)) end

local surface
local function place(spec, what)
  spec.force = "player"
  local e = surface.create_entity(spec)
  if not e then out("FIXTURE FAILED: %s at (%s, %s)", what, spec.position[1], spec.position[2]) end
  return e
end

local function seg(e) return e.has_fluid_segment(1) and e.get_fluid_segment_id(1) or "-" end

local function power(x, y)
  place({ name = "small-electric-pole", position = { x + 0.5, y + 1.5 } }, "pole")
  local eei = place({ name = "electric-energy-interface", position = { x + 1, y + 3 } }, "energy interface")
  if eei then
    eei.electric_buffer_size = 1e9
    eei.power_production = 1e7
  end
end

-- A line of `len` tiles from (x, y) eastwards (or southwards with `south`): Pipe-to-ground pairs
-- at their full reach (11 tiles a pair), the rest plain pipes. Returns the first and last entity.
local function line(x, y, len, south)
  local first, last
  local function at(i) if south then return { x + 0.5, y + i + 0.5 } end return { x + i + 0.5, y + 0.5 } end
  local back, ahead = south and defines.direction.north or W, south and defines.direction.south or E
  local i = 0
  while len - i >= 11 do
    local a = place({ name = "pipe-to-ground", position = at(i), direction = back }, "ptg")
    last = place({ name = "pipe-to-ground", position = at(i + 10), direction = ahead }, "ptg")
    first = first or a
    i = i + 11
  end
  while i < len do
    last = place({ name = "pipe", position = at(i) }, "pipe")
    first = first or last
    i = i + 1
  end
  return first, last
end

-- device: "pump" (2 tiles), "valve" (1 tile) or nil; returns the tiles it took.
local function device(kind, x, y)
  if kind == "pump" then
    place({ name = "pump", position = { x + 1, y + 0.5 }, direction = E }, "pump")
    power(x, y)
    return 2
  elseif kind == "valve" then
    place({ name = "py-check-valve", position = { x + 0.5, y + 0.5 }, direction = E }, "valve")
    return 1
  end
  return 0
end

local X0 = -330
storage.lines, storage.tanks = {}, {}

local function throughput_case(row, label, len1, kind, len2)
  local y = row * 8
  local src = place({ name = "infinity-pipe", position = { X0 - 0.5, y + 0.5 } }, "source")
  src.set_infinity_pipe_filter({ name = "steam", percentage = 1, temperature = 250, mode = "at-least" })
  local x = X0
  local a1, b1 = line(x, y, len1)
  x = x + len1
  x = x + device(kind, x, y)
  local a2, b2 = line(x, y, len2)
  x = x + len2
  place({ name = "py-check-valve", position = { x + 0.5, y + 0.5 }, direction = E }, "sink valve")
  local sink = place({ name = "pipe", position = { x + 1.5, y + 0.5 } }, "sink pipe")
  local segs = {}
  local parts = { src, a1, b1, a2, b2, sink }
  for i = 1, 6 do if parts[i] then segs[#segs + 1] = tostring(seg(parts[i])) end end
  storage.lines[#storage.lines + 1] = { label = label, sink = sink, got = 0, segs = table.concat(segs, "/"), last = b2 or b1 }
end

local function tank_case(row, label, kind, fa, fb)
  local y = row * 8
  local x = X0
  local a1, b1 = line(x, y, 100)
  x = x + 100 + device(kind, x + 100, y)
  local a2, b2 = line(x, y, 100)
  a1.set_fluid_segment_fluid(1, { name = "steam", amount = fa * a1.get_fluid_segment_capacity(1), temperature = 250 })
  a2.set_fluid_segment_fluid(1, { name = "steam", amount = fb * a2.get_fluid_segment_capacity(1), temperature = 250 })
  storage.tanks[#storage.tanks + 1] = { label = label, a = a1, b = a2 }
end

local function amount(e)
  local f = e.get_fluid_segment_fluid(1)
  return f and f.amount or 0
end

script.on_init(function()
  surface = game.surfaces.nauvis
  surface.request_to_generate_chunks({ 0, 0 }, 11)
  surface.force_generate_chunk_requests()
  for _, area in ipairs({ { { -345, -10 }, { 345, 130 } }, { { -345, 130 }, { -110, 360 } } }) do
    for _, e in pairs(surface.find_entities(area)) do if e.valid then e.destroy() end end
  end
  local tiles = {}
  for x = -345, 344 do for y = -10, 129 do tiles[#tiles + 1] = { name = "lab-dark-1", position = { x, y } } end end
  for x = -345, -111 do for y = 130, 359 do tiles[#tiles + 1] = { name = "lab-dark-1", position = { x, y } } end end
  surface.set_tiles(tiles)

  throughput_case(0, "310 tiles, no device", 0, nil, 310)
  throughput_case(1, "330 tiles, no device", 0, nil, 330)
  throughput_case(2, "625 tiles, no device", 0, nil, 625)
  throughput_case(3, "625 tiles, Pump at tile 310", 310, "pump", 313)
  throughput_case(4, "625 tiles, Check valve at tile 310", 310, "valve", 314)
  throughput_case(5, "625 tiles, Pump at tile 205 (420 after it)", 205, "pump", 418)
  throughput_case(6, "55 tiles, no device", 0, nil, 55)

  -- An L: 200 tiles east, a corner pipe, 200 tiles south. 400 tiles of pipe in a 202 x 202 box.
  do
    local y = 150
    local src = place({ name = "infinity-pipe", position = { X0 - 0.5, y + 0.5 } }, "source")
    src.set_infinity_pipe_filter({ name = "steam", percentage = 1, temperature = 250, mode = "at-least" })
    local a1 = line(X0, y, 200)
    place({ name = "pipe", position = { X0 + 200.5, y + 0.5 } }, "corner")
    local _, b2 = line(X0 + 200, y + 1, 200, true)
    place({ name = "py-check-valve", position = { X0 + 200.5, y + 201.5 }, direction = defines.direction.south }, "sink valve")
    local sink = place({ name = "pipe", position = { X0 + 200.5, y + 202.5 } }, "sink pipe")
    storage.lines[#storage.lines + 1] = { label = "L of 200 east + 200 south, no device", sink = sink, got = 0,
      segs = tostring(seg(a1)) .. "/" .. tostring(seg(b2)), last = b2 }
  end

  tank_case(9, "Pump, 20 % -> 80 %", "pump", 0.2, 0.8)
  tank_case(10, "Check valve, 20 % -> 80 %", "valve", 0.2, 0.8)
  tank_case(11, "Check valve, 80 % -> 20 %", "valve", 0.8, 0.2)
  tank_case(12, "Pump, 80 % -> 20 %", "pump", 0.8, 0.2)
  tank_case(13, "Plain pipe (one segment), 20 % / 80 %", nil, 0.2, 0.8)

  for _, t in ipairs(storage.tanks) do
    out("start %s: A %.0f, B %.0f (segments %s/%s)", t.label, amount(t.a), amount(t.b), tostring(seg(t.a)), tostring(seg(t.b)))
  end
  for _, l in ipairs(storage.lines) do out("built %s: segments %s", l.label, l.segs) end
end)

script.on_event(defines.events.on_tick, function(event)
  local t = event.tick
  for _, l in ipairs(storage.lines) do
    local f = l.sink.get_fluid_segment_fluid(1)
    if f then
      if t > WARM then l.got = l.got + f.amount end
      l.sink.clear_fluid_segment_fluid(1)
    end
  end
  if t == WARM + MEASURE then
    for _, l in ipairs(storage.lines) do
      out("%s: %.1f steam/s arrive; line end segment holds %.0f", l.label, l.got * 60 / MEASURE, amount(l.last))
    end
    for _, tk in ipairs(storage.tanks) do
      out("after %.0f s %s: A %.0f, B %.0f", (t) / 60, tk.label, amount(tk.a), amount(tk.b))
    end
  end
end)
