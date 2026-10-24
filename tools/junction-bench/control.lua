-- Junction bench: builds one rail junction (rails and signals of a blueprint) on an empty lab
-- surface and measures it.
--   mode "map": writes the junction's rails, signals, rail blocks, open rail ends and the path
--     between every pair of open ends, with the signals met on the way, to
--     script-output/junction-bench/<name>-map.json (rendered by tools/junction-bench.js).
--   mode "traffic": extends every open track end with straight track (options.extend tiles, rail
--     signals every options.spacing tiles), finds the entrances and exits by the pathfinder, puts
--     one train stop per exit leg at the end of each exit track, and keeps a train waiting at the
--     far end of every entrance track: each goes to a leg the scenario picks (options.scenario:
--     mix = straight, left or right at random; straight; left; right) and is removed once its
--     last car is options.clear tiles past the junction. options.source = "leg": one queue per
--     leg instead, each train placed on an entrance track that leads where it goes (for junctions
--     whose lanes serve different turns). options.speed: km/h at which a train starts when the
--     options.ahead tiles in front of it are clear. After options.warm minutes it counts,
--     for options.minutes, the trains through per movement, the time from the junction edge until
--     the train has left it, its speed at the edge and the signals trains stand at inside the
--     junction; it reports a deadlock when no train leaves for options.stall seconds.
--   mode "edit": changes the signals (see edit_mode) and writes the junction as a blueprint string.
--   mode "ends": prints the signal places of the rail ends at options.at (for placing signals).
-- Results are CF-JUNCTION log lines. Run by tools/junction-bench.ps1, which writes bench-data.lua:
-- the name, the mode, the options and the blueprint's entities as JSON.

local data = require("bench-data")
local opts = helpers.json_to_table(data.options or "{}") or {}
local entities = helpers.json_to_table(data.entities)
local function opt(k, v) if opts[k] == nil then opts[k] = v end end
opt("extend", 320); opt("spacing", 30); opt("clear", 60); opt("warm", 3); opt("minutes", 20)
opt("stall", 120); opt("scenario", "mix"); opt("seed", 1); opt("wagons", 2); opt("fuel", "coal")
opt("locomotive", "locomotive"); opt("wagon", "cargo-wagon"); opt("speed", 0); opt("ahead", 200); opt("source", "lane")

local function out(fmt, ...) log("CF-JUNCTION " .. string.format(fmt, ...)) end
local RD = defines.rail_direction
local RCD = defines.rail_connection_direction
local CONN = { RCD.left, RCD.straight, RCD.right }
local LEG = { [0] = "N", [4] = "E", [8] = "S", [12] = "W" }
local function r3(v) return math.floor(v * 1000 + 0.5) / 1000 end

-- Unit vector of a 16-way direction (0 = north, clockwise).
local function unit(d)
  local a = d * math.pi / 8
  local x, y = math.sin(a), -math.cos(a)
  if math.abs(x) < 1e-9 then x = 0 end
  if math.abs(y) < 1e-9 then y = 0 end
  return x, y
end

local function build(surface)
  local x1, y1, x2, y2 = math.huge, math.huge, -math.huge, -math.huge
  for _, e in ipairs(entities) do
    x1, y1 = math.min(x1, e.position.x), math.min(y1, e.position.y)
    x2, y2 = math.max(x2, e.position.x), math.max(y2, e.position.y)
  end
  -- Shift by whole rail-grid steps (2 tiles) so the junction sits around the origin.
  local dx, dy = -2 * math.floor((x1 + x2) / 4), -2 * math.floor((y1 + y2) / 4)
  local half = math.max(x2 - x1, y2 - y1) / 2 + (data.mode == "traffic" and opts.extend or 0) + 64
  local chunks = math.ceil(half / 32) + 1
  for cx = -chunks, chunks do
    for cy = -chunks, chunks do surface.request_to_generate_chunks({ cx * 32, cy * 32 }, 0) end
  end
  surface.force_generate_chunk_requests()
  local made, failed = 0, {}
  -- Rails first: signals need a rail beside them.
  for pass = 1, 2 do
    for _, e in ipairs(entities) do
      local is_signal = e.name == "rail-signal" or e.name == "rail-chain-signal"
      if (pass == 2) == is_signal then
        local ent = surface.create_entity({ name = e.name, position = { e.position.x + dx, e.position.y + dy },
          direction = e.direction or 0, force = "player" })
        if ent then made = made + 1 else failed[#failed + 1] = string.format("%s@%s,%s", e.name, e.position.x, e.position.y) end
      end
    end
  end
  out("built %d of %d entities (shift %d,%d)%s", made, #entities, dx, dy,
    #failed > 0 and ("; failed: " .. table.concat(failed, " ")) or "")
  return { x1 = x1 + dx, y1 = y1 + dy, x2 = x2 + dx, y2 = y2 + dy }
end

local RAIL_TYPES = { "straight-rail", "half-diagonal-rail", "curved-rail-a", "curved-rail-b" }
local function rails_of(surface) return surface.find_entities_filtered({ type = RAIL_TYPES }) end

-- The rails joined to one end of a rail.
local function connected(rail, dir)
  local list = {}
  for _, c in ipairs(CONN) do
    local r, rdir = rail.get_connected_rail({ rail_direction = dir, rail_connection_direction = c })
    if r then list[#list + 1] = { rail = r, dir = rdir, conn = c } end
  end
  return list
end

local function other(dir) return dir == RD.front and RD.back or RD.front end

-- Open rail ends (nothing joined), merged by position into track ends.
local function track_ends(rails)
  local by, list = {}, {}
  for _, rail in ipairs(rails) do
    for _, dir in ipairs({ RD.front, RD.back }) do
      if #connected(rail, dir) == 0 then
        local l = rail.get_rail_end(dir).location
        local key = l.position.x .. "," .. l.position.y
        if not by[key] then
          by[key] = { x = l.position.x, y = l.position.y, d = l.direction, rails = {} }
          list[#list + 1] = by[key]
        end
        local t = by[key]
        t.rails[#t.rails + 1] = { rail = rail, dir = dir }
      end
    end
  end
  table.sort(list, function(a, b)
    if a.d ~= b.d then return a.d < b.d end
    if a.x ~= b.x then return a.x < b.x end
    return a.y < b.y
  end)
  return list
end

-- Which end of `a` leads to `b`.
local function end_towards(a, b)
  for _, dir in ipairs({ RD.front, RD.back }) do
    for _, c in ipairs(connected(a, dir)) do
      if c.rail == b then return dir end
    end
  end
end

-- The signal a train passes going from rail a to rail b: one standing where the rail end between
-- them puts a signal for that direction of travel (either of its two places). The second result
-- says whether a rail-segment boundary lies there.
local function signal_between(a, b)
  local dir, back = end_towards(a, b), end_towards(b, a)
  if not dir then return nil, false end
  -- Places for that direction: the outgoing ones of a's end and the incoming ones of b's end.
  local ra, rb = a.get_rail_end(dir), back and b.get_rail_end(back)
  local places = { ra.out_signal_location, ra.alternative_out_signal_location }
  if rb then places[#places + 1] = rb.in_signal_location; places[#places + 1] = rb.alternative_in_signal_location end
  for _, l in pairs(places) do
    for _, s in ipairs(a.surface.find_entities_filtered({ position = l.position, type = { "rail-signal", "rail-chain-signal" } })) do
      if s.direction == l.direction then return s, true end
    end
  end
  return nil, not a.is_rail_in_same_rail_segment_as(b)
end

-- ---------- map ----------

local function block_ids(rails)
  local reps, block = {}, {}
  for i, r in ipairs(rails) do
    for b, rep in ipairs(reps) do
      if r.is_rail_in_same_rail_block_as(rep) then block[i] = b; break end
    end
    if not block[i] then reps[#reps + 1] = r; block[i] = #reps end
  end
  return block, #reps
end

local function map_mode(surface, box)
  local rails = rails_of(surface)
  local id = {}
  for i, r in ipairs(rails) do id[r.unit_number] = i end
  local block, nblocks = block_ids(rails)
  local result = { name = data.name, box = box, rails = {}, signals = {}, ends = {}, paths = {} }
  for i, r in ipairs(rails) do
    local ends = {}
    for _, dir in ipairs({ RD.front, RD.back }) do
      local l = r.get_rail_end(dir).location
      local joined = {}
      for _, c in ipairs(connected(r, dir)) do joined[#joined + 1] = id[c.rail.unit_number] end
      ends[#ends + 1] = { x = l.position.x, y = l.position.y, d = l.direction, joined = joined }
    end
    result.rails[i] = { name = r.name, x = r.position.x, y = r.position.y, d = r.direction,
      length = r3(r.rail_length), block = block[i], ends = ends }
  end
  local sigid = {}
  for i, s in ipairs(surface.find_entities_filtered({ type = { "rail-signal", "rail-chain-signal" } })) do
    sigid[s.unit_number] = i
    local on = {}
    for _, r in ipairs(s.get_connected_rails()) do on[#on + 1] = id[r.unit_number] end
    result.signals[i] = { name = s.name, x = s.position.x, y = s.position.y, d = s.direction, rails = on }
  end
  local ends = track_ends(rails)
  for i, e in ipairs(ends) do
    local rs = {}
    for k, t in ipairs(e.rails) do rs[k] = id[t.rail.unit_number] end
    result.ends[i] = { rails = rs, x = e.x, y = e.y, d = e.d }
  end
  -- Paths between track ends, and the signal at every rail-segment boundary on the way
  -- (0 = a boundary without a signal, a switch).
  for si, s in ipairs(ends) do
    for gi, g in ipairs(ends) do
      if si ~= gi then
        local starts, goals = {}, {}
        for _, t in ipairs(s.rails) do starts[#starts + 1] = { rail = t.rail, direction = other(t.dir) } end
        for _, t in ipairs(g.rails) do goals[#goals + 1] = { rail = t.rail, direction = t.dir } end
        local res = game.train_manager.request_train_path({ type = "path", return_path = true,
          shortest_path = true, starts = starts, goals = goals })
        if res.found_path then
          local steps, list = {}, res.path
          for k = 1, #list - 1 do
            local sig, boundary = signal_between(list[k], list[k + 1])
            if boundary then steps[#steps + 1] = { at = k, sig = sig and sigid[sig.unit_number] or 0 } end
          end
          local ids = {}
          for k, r in ipairs(list) do ids[k] = id[r.unit_number] end
          result.paths[#result.paths + 1] = { from = si, to = gi, length = r3(res.total_length), rails = ids, steps = steps }
        end
      end
    end
  end
  helpers.write_file("junction-bench/" .. data.name .. "-map.json", helpers.table_to_json(result), false)
  out("%d rails, %d signals, %d blocks, %d track ends, %d paths", #rails, #result.signals, nblocks, #ends, #result.paths)
end

-- ---------- traffic ----------

-- Straight track from a track end outward, `length` tiles; returns the rails, nearest first.
local function extend(surface, e, length)
  local ux, uy = unit(e.d)
  if ux ~= 0 and uy ~= 0 then error("diagonal track end at " .. e.x .. "," .. e.y) end
  local list = {}
  for k = 0, length / 2 - 1 do
    local r = surface.create_entity({ name = "straight-rail", position = { e.x + ux * (2 * k + 1), e.y + uy * (2 * k + 1) },
      direction = e.d % 8, force = "player" })
    if not r then error("could not extend " .. e.x .. "," .. e.y) end
    list[#list + 1] = r
  end
  return list
end

-- The end of a straight rail facing along (ux, uy).
local function end_facing(rail, ux, uy)
  for _, dir in ipairs({ RD.front, RD.back }) do
    local p = rail.get_rail_end(dir).location.position
    if (p.x - rail.position.x) * ux + (p.y - rail.position.y) * uy > 0 then return dir end
  end
end

-- A signal guarding travel along (ux, uy) at the end of `rail` that faces that way.
local function place_signal(surface, rail, ux, uy, name)
  local re = rail.get_rail_end(end_facing(rail, ux, uy))
  local l = re.out_signal_location
  return surface.create_entity({ name = name or "rail-signal", position = l.position, direction = l.direction, force = "player" })
end

local function gap(a, b)
  local pa, pb = prototypes.entity[a], prototypes.entity[b]
  return (pa.joint_distance + pb.joint_distance) / 2 + (pa.connection_distance + pb.connection_distance) / 2
end

local T = {}

-- A track end 2 tiles inside another one on the same line (a blueprint cut short at its edge):
-- joined with one straight rail, and reported.
local function fill_gaps(surface)
  local ends = track_ends(rails_of(surface))
  local filled = {}
  for _, e in ipairs(ends) do
    local ux, uy = unit(e.d)
    for _, f in ipairs(ends) do
      if f.d == e.d and math.abs(f.x - (e.x + 2 * ux)) < 0.01 and math.abs(f.y - (e.y + 2 * uy)) < 0.01 then
        if surface.create_entity({ name = "straight-rail", position = { e.x + ux, e.y + uy }, direction = e.d % 8, force = "player" }) then
          filled[#filled + 1] = string.format("%s,%s", e.x, e.y)
        end
      end
    end
  end
  if #filled > 0 then out("filled %d two-tile gaps at the edge (straight rail missing beyond %s)", #filled, table.concat(filled, " ")) end
end

local function traffic_setup(surface, box)
  fill_gaps(surface)
  local ends = track_ends(rails_of(surface))
  T.box = box
  T.legs, T.tracks = {}, {}
  for i, e in ipairs(ends) do
    local ux, uy = unit(e.d)
    local t = { i = i, x = e.x, y = e.y, d = e.d, ux = ux, uy = uy, leg = LEG[e.d], ends = e.rails,
      rails = extend(surface, e, opts.extend) }
    T.tracks[i] = t
    T.legs[t.leg] = T.legs[t.leg] or { name = t.leg, d = e.d, inn = {}, out = {} }
  end
  -- Entrances: track ends from which the far end of another leg's track can be reached.
  for _, s in ipairs(T.tracks) do
    for _, g in ipairs(T.tracks) do
      if s ~= g and s.leg ~= g.leg and not s.inbound then
        local sr, gr = s.rails[#s.rails], g.rails[#g.rails]
        local res = game.train_manager.request_train_path({ type = "any-goal-accessible",
          starts = { { rail = sr, direction = end_facing(sr, -s.ux, -s.uy) } },
          goals = { { rail = gr, direction = end_facing(gr, g.ux, g.uy) } } })
        if res.found_path then s.inbound = true end
      end
    end
  end
  for _, t in ipairs(T.tracks) do
    local leg = T.legs[t.leg]
    if t.inbound then leg.inn[#leg.inn + 1] = t else leg.out[#leg.out + 1] = t end
    -- Rail signals along the extension, from `spacing` tiles out, facing the way trains run.
    local sx, sy = t.ux, t.uy
    if t.inbound then sx, sy = -sx, -sy end
    for k = opts.spacing / 2, #t.rails - 2, opts.spacing / 2 do place_signal(surface, t.rails[k], sx, sy) end
    if not t.inbound then
      -- The train stop at the far end, on the right of the track.
      local far = t.rails[#t.rails - 1]
      local rx, ry = -t.uy, t.ux
      t.stop = surface.create_entity({ name = "train-stop", position = { far.position.x + 2 * rx, far.position.y + 2 * ry },
        direction = t.d, force = "player" })
      if not t.stop or not t.stop.connected_rail then
        if t.stop then t.stop.destroy() end
        t.stop = surface.create_entity({ name = "train-stop", position = { far.position.x - 2 * rx, far.position.y - 2 * ry },
          direction = t.d, force = "player" })
      end
      if t.stop then t.stop.backer_name = "exit " .. t.leg end
    end
  end
  local parts = {}
  for _, name in ipairs({ "N", "E", "S", "W" }) do
    local leg = T.legs[name]
    if leg then parts[#parts + 1] = string.format("%s: %d in, %d out", name, #leg.inn, #leg.out) end
  end
  out("legs %s", table.concat(parts, "; "))
  -- Every exit leg's train stops reachable from the far end of every entrance track.
  for _, s in ipairs(T.tracks) do
    if s.inbound then
      local sr = s.rails[#s.rails]
      local got = {}
      for _, name in ipairs({ "N", "E", "S", "W" }) do
        local leg = T.legs[name]
        if leg and name ~= s.leg then
          local goals = {}
          for _, g in ipairs(leg.out) do if g.stop then goals[#goals + 1] = g.stop end end
          local res = #goals > 0 and game.train_manager.request_train_path({ type = "any-goal-accessible",
            starts = { { rail = sr, direction = end_facing(sr, -s.ux, -s.uy) } }, goals = goals })
          s.reach = s.reach or {}
          s.reach[name] = res and res.found_path or false
          got[#got + 1] = name .. (res and res.found_path and " yes" or " NO") .. " (" .. #goals .. " stops)"
        end
      end
      out("from the far end of %s%d: %s", s.leg, s.i, table.concat(got, ", "))
    end
  end
  -- Every movement's shortest path from the entrance edge.
  for _, s in ipairs(T.tracks) do
    if s.inbound then
      for _, leg in pairs(T.legs) do
        if leg.name ~= s.leg and #leg.out > 0 then
          local goals = {}
          for _, g in ipairs(leg.out) do goals[#goals + 1] = { rail = g.rails[1], direction = end_facing(g.rails[1], g.ux, g.uy) } end
          local sr = s.rails[1]
          local res = game.train_manager.request_train_path({ type = "path", shortest_path = true,
            starts = { { rail = sr, direction = end_facing(sr, -s.ux, -s.uy) } }, goals = goals })
          out("path %s%d -> %s: %s", s.leg, s.i, leg.name, res.found_path and string.format("%.1f tiles", res.total_length) or "none")
        end
      end
    end
  end
  T.seed = opts.seed
  T.trains, T.done, T.stats = {}, {}, {}
  T.start = opts.warm * 3600
  T.stop_tick = T.start + opts.minutes * 3600
  T.last_exit = 0
  T.waits = {}
  T.samples = 0
end

-- The exit leg for a train from leg `from` (outward direction d_in), by the scenario.
local function pick(from)
  local turns = { straight = 8, left = 4, right = 12 }
  local kind = opts.scenario
  if kind == "mix" then
    T.seed = (T.seed * 1103515245 + 12345) % 2147483648
    kind = ({ "straight", "left", "right" })[math.floor(T.seed / 65536) % 3 + 1]
  end
  return LEG[(from.d + turns[kind]) % 16], kind
end

-- Whether the far end of an entrance track is clear: one train waiting there at a time.
local function zone_free(surface, t)
  local p1, p2 = t.rails[#t.rails].position, t.rails[#t.rails - 30].position
  local area = { { math.min(p1.x, p2.x) - 3, math.min(p1.y, p2.y) - 3 }, { math.max(p1.x, p2.x) + 3, math.max(p1.y, p2.y) + 3 } }
  return surface.count_entities_filtered({ area = area, type = { "locomotive", "cargo-wagon", "fluid-wagon" } }) == 0
end

local function spawn(surface, t, tick, to, kind)
  local far = t.rails[#t.rails - 6 - 4 * opts.wagons]
  local dir = (t.d + 8) % 16
  local stock = { opts.locomotive }
  for _ = 1, opts.wagons do stock[#stock + 1] = opts.wagon end
  local x, y = far.position.x, far.position.y
  local cars = {}
  for k, name in ipairs(stock) do
    if k > 1 then
      local g = gap(stock[k - 1], name)
      x, y = x + t.ux * g, y + t.uy * g
    end
    local c = surface.create_entity({ name = name, position = { x, y }, direction = dir, force = "player" })
    if not c then
      for _, o in ipairs(cars) do o.destroy() end
      return
    end
    cars[#cars + 1] = c
    if c.type == "locomotive" then c.get_fuel_inventory().insert({ name = opts.fuel, count = 20 }) end
  end
  local train = cars[1].train
  if #train.carriages ~= #stock then out("spawned train %d coupled to another (%d cars)", train.id, #train.carriages) end
  local schedule = train.get_schedule()
  schedule.add_record({ station = "exit " .. to })
  schedule.go_to_station(1)
  train.manual_mode = false
  -- Trains arrive at line speed when the track ahead is clear enough to brake on.
  if opts.speed > 0 then
    local k = math.max(1, #t.rails - 6 - 4 * opts.wagons - opts.ahead / 2)
    local q1, q2 = far.position, t.rails[k].position
    local ahead = { { math.min(q1.x, q2.x) - 3, math.min(q1.y, q2.y) - 3 }, { math.max(q1.x, q2.x) + 3, math.max(q1.y, q2.y) + 3 } }
    if surface.count_entities_filtered({ area = ahead, type = { "locomotive", "cargo-wagon", "fluid-wagon" } }) == #stock then
      train.speed = opts.speed / 216
    end
  end
  T.trains[train.id] = { train = train, from = t.leg, track = t.i, to = to, kind = kind, spawned = tick }
end

local function inside(p)
  local b = T.box
  return p.x >= b.x1 and p.x <= b.x2 and p.y >= b.y1 and p.y <= b.y2
end

local function stat(key)
  local s = T.stats[key]
  if not s then s = { n = 0, time = 0, max = 0, wait = 0 }; T.stats[key] = s end
  return s
end

local function report(tick, deadlock)
  local total, time, max = 0, 0, 0
  local keys = {}
  for k in pairs(T.stats) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local s = T.stats[k]
    total, time, max = total + s.n, time + s.time, math.max(max, s.max)
    out("  %-12s %4d trains, through the junction %.1f s on average (max %.1f), from spawn %.1f s", k, s.n,
      s.time / s.n / 60, s.max / 60, s.wait / s.n / 60)
  end
  local list = {}
  for _, w in pairs(T.waits) do list[#list + 1] = w end
  table.sort(list, function(a, b) return a.n > b.n end)
  for k = 1, math.min(12, #list) do
    local w = list[k]
    out("  waiting at %s %.1f,%.1f: %.0f%% of samples", w.name, w.x, w.y, 100 * w.n / math.max(1, T.samples))
  end
  local minutes = (math.min(tick, T.stop_tick) - T.start) / 3600
  out("%s scenario %s: %d trains in %.1f min = %.2f trains/min; through the junction %.1f s on average (max %.1f); entering at %.0f km/h on average%s",
    data.name, opts.scenario, total, minutes, total / minutes, total > 0 and time / total / 60 or 0, max / 60,
    (T.v_in or 0) / math.max(1, T.n_in or 0), deadlock and "; DEADLOCK" or "")
end

local function traffic_tick(tick)
  local surface = game.surfaces.junction
  if tick % 30 == 0 then
    if opts.source == "leg" then
      -- One queue per leg: the next train's movement is drawn first, then it waits for a free
      -- entrance track that leads there.
      T.pending = T.pending or {}
      for name, leg in pairs(T.legs) do
        if #leg.inn > 0 then
          local p = T.pending[name]
          if not p then
            local to, kind = pick(leg.inn[1])
            p = { to = to, kind = kind }
            T.pending[name] = p
          end
          local free = {}
          for _, t in ipairs(leg.inn) do
            if t.reach and t.reach[p.to] and zone_free(surface, t) then free[#free + 1] = t end
          end
          if #free > 0 then
            T.seed = (T.seed * 1103515245 + 12345) % 2147483648
            spawn(surface, free[math.floor(T.seed / 65536) % #free + 1], tick, p.to, p.kind)
            T.pending[name] = nil
          end
        end
      end
    else
      for _, t in ipairs(T.tracks) do
        if t.inbound and zone_free(surface, t) then
          local to, kind = pick(t)
          spawn(surface, t, tick, to, kind)
        end
      end
    end
  end
  if tick % 10 ~= 0 then return end
  for id, r in pairs(T.trains) do
    local train = r.train
    if not train.valid then
      T.trains[id] = nil
    else
      local front, back = train.front_stock.position, train.back_stock.position
      local carriage_inside = false
      for _, c in ipairs(train.carriages) do if inside(c.position) then carriage_inside = true end end
      if not r.entered and inside(front) then r.entered = tick; r.v_in = math.abs(train.speed) * 216 end
      if carriage_inside and math.abs(train.speed) < 1e-4 and tick >= T.start and tick < T.stop_tick then
        -- Where trains stand inside the junction: the signal they wait at.
        local sig = train.signal
        local key = sig and sig.valid and sig.unit_number or ("state " .. train.state)
        if not (sig and sig.valid) and (T.nosig or 0) < 8 and tick % 600 == 0 then
          T.nosig = (T.nosig or 0) + 1
          out("stopped without a signal: train %d %s->%s front %.1f,%.1f back %.1f,%.1f state %d", train.id, r.from, r.to,
            front.x, front.y, back.x, back.y, train.state)
        end
        local w = T.waits[key]
        if not w then
          w = { n = 0, name = sig and sig.valid and sig.name or ("no signal, state " .. train.state), x = sig and sig.valid and sig.position.x or front.x,
            y = sig and sig.valid and sig.position.y or front.y }
          T.waits[key] = w
        end
        w.n = w.n + 1
      end
      if r.entered and not carriage_inside then
        -- Left the junction: measure, then remove once well clear of it.
        r.left = r.left or tick
        local leg = T.legs[r.to]
        local ux, uy = unit(leg.d)
        local b = T.box
        local edge = (ux > 0 and b.x2 or b.x1) * ux + (uy > 0 and b.y2 or b.y1) * uy
        local beyond = math.min(front.x * ux + front.y * uy, back.x * ux + back.y * uy) - edge
        if beyond > opts.clear or train.state == defines.train_state.wait_station then
          if tick >= T.start and tick < T.stop_tick then
            local s = stat(r.from .. "->" .. r.to .. " " .. r.kind)
            local dt = r.left - r.entered
            s.n, s.time, s.max, s.wait = s.n + 1, s.time + dt, math.max(s.max, dt), s.wait + (r.left - r.spawned)
            T.v_in, T.n_in = (T.v_in or 0) + r.v_in, (T.n_in or 0) + 1
          end
          T.last_exit = tick
          for _, c in ipairs(train.carriages) do c.destroy() end
          T.trains[id] = nil
        end
      end
      if train.valid and train.state == defines.train_state.no_path then
        r.no_path = (r.no_path or 0) + 1
        if r.no_path == 30 then
          out("train %d %s%d -> %s has no path at %.1f,%.1f (back %.1f,%.1f), speed %.3f, %d cars", id, r.from, r.track, r.to,
            front.x, front.y, back.x, back.y, train.speed, #train.carriages)
        end
      end
    end
  end
  if tick >= T.start and tick < T.stop_tick then
    T.samples = T.samples + 1
  end
  if not T.reported and tick - math.max(T.last_exit, 600) > opts.stall * 60 then
    T.reported = true
    out("DEADLOCK: no train left for %d s at tick %d", opts.stall, tick)
    for id, r in pairs(T.trains) do
      local f = r.train.front_stock.position
      out("  train %d %s->%s at %.1f,%.1f state %d speed %.3f", id, r.from, r.to, f.x, f.y, r.train.state, r.train.speed)
    end
    report(tick, true)
  end
  if tick == T.stop_tick - (T.stop_tick % 10) and not T.reported then
    T.reported = true
    report(tick, false)
  end
end

-- ---------- edit ----------

local SIGNAL_TYPES = { "rail-signal", "rail-chain-signal" }
local SECTOR = {
  N = function(x, y) return y < -math.abs(x) end, E = function(x, y) return x > math.abs(y) end,
  S = function(x, y) return y > math.abs(x) end, W = function(x, y) return x < -math.abs(y) end,
}
local TURN = { N = 0, E = 1, S = 2, W = 3 } -- quarter turns clockwise from north

local function set_signal(surface, name, position, direction)
  for _, old in ipairs(surface.find_entities_filtered({ position = position, type = SIGNAL_TYPES })) do old.destroy() end
  return surface.create_entity({ name = name, position = position, direction = direction, force = "player" })
end

-- Edits a junction's signals (options.edit), in this order:
--   remove_rails = {{x, y}, ...}: the rails there and at the same places on the other three sides
--     removed, with the signals left without a rail,
--   remove = {{x, y}, ...}: the signals there removed,
--   chain_inside = true: every rail signal turned into a chain signal,
--   edges = true: a chain signal (or entry = "rail-signal") where each entrance track enters the
--     junction and a rail signal where each exit track leaves it (entrances found by the
--     pathfinder, or entrances = {"S", ...} names the legs),
--   add = {{x, y, d, name}, ...}: signals placed (or replaced) there,
--   copy = "E": every leg's signals replaced by the named leg's, turned (for a junction meant to be
--     the same from all four sides; the centre is the middle of the track ends).
-- Then writes the junction as a blueprint string to script-output/junction-bench/<name>.txt.
local function edit_mode(surface)
  local e = opts.edit or {}
  local ends = track_ends(rails_of(surface))
  local xs, ys = {}, {}
  for _, t in ipairs(ends) do xs[#xs + 1] = t.x; ys[#ys + 1] = t.y end
  local cx = (math.min(table.unpack(xs)) + math.max(table.unpack(xs))) / 2
  local cy = (math.min(table.unpack(ys)) + math.max(table.unpack(ys))) / 2
  if e.remove_rails then
    -- The rails at these places and at the same places turned 90, 180 and 270 degrees, then every
    -- signal left without a rail.
    local n, s_n = 0, 0
    for _, p in ipairs(e.remove_rails) do
      local x, y = p[1] - cx, p[2] - cy
      for _ = 1, 4 do
        for _, r in ipairs(surface.find_entities_filtered({ position = { x + cx, y + cy }, type = RAIL_TYPES })) do
          r.destroy(); n = n + 1
        end
        x, y = -y, x
      end
    end
    for _, sig in ipairs(surface.find_entities_filtered({ type = SIGNAL_TYPES })) do
      if #sig.get_connected_rails() == 0 then sig.destroy(); s_n = s_n + 1 end
    end
    out("remove_rails: %d rails and %d signals without a rail removed", n, s_n)
    ends = track_ends(rails_of(surface))
  end
  for _, p in ipairs(e.remove or {}) do
    for _, sig in ipairs(surface.find_entities_filtered({ position = { p[1], p[2] }, type = SIGNAL_TYPES })) do sig.destroy() end
  end
  if e.chain_inside then
    local n = 0
    for _, sig in ipairs(surface.find_entities_filtered({ name = "rail-signal" })) do
      local p, d = sig.position, sig.direction
      sig.destroy()
      if surface.create_entity({ name = "rail-chain-signal", position = p, direction = d, force = "player" }) then n = n + 1 end
    end
    out("chain_inside: %d rail signals made chain signals", n)
  end
  if e.edges then
    local n_in, n_out = 0, 0
    for _, s0 in ipairs(ends) do
      local starts = {}
      for _, t in ipairs(s0.rails) do starts[#starts + 1] = { rail = t.rail, direction = other(t.dir) } end
      local goals = {}
      for _, g in ipairs(ends) do
        if g.d ~= s0.d then for _, t in ipairs(g.rails) do goals[#goals + 1] = { rail = t.rail, direction = t.dir } end end
      end
      local res = game.train_manager.request_train_path({ type = "any-goal-accessible", starts = starts, goals = goals })
      local re = s0.rails[1].rail.get_rail_end(s0.rails[1].dir)
      local entrance = res.found_path
      -- entrances = {"S", ...}: the legs trains come in by, for track that has no signal to tell.
      if e.entrances then
        entrance = false
        for _, leg in ipairs(e.entrances) do if LEG[s0.d] == leg then entrance = true end end
      end
      if entrance then
        local l = re.in_signal_location
        if set_signal(surface, e.entry or "rail-chain-signal", l.position, l.direction) then n_in = n_in + 1 end
      else
        local l = re.out_signal_location
        if set_signal(surface, "rail-signal", l.position, l.direction) then n_out = n_out + 1 end
      end
    end
    out("edges: %d entrance %ss, %d exit rail signals", n_in, e.entry or "rail-chain-signal", n_out)
  end
  for _, a in ipairs(e.add or {}) do
    if not set_signal(surface, a.name, { a.x, a.y }, a.d) then out("add: no %s fits at %s,%s", a.name, a.x, a.y) end
  end
  if e.add then out("add: %d signals placed", #e.add) end
  if e.copy then
    local from = e.copy
    local list = {}
    for _, sig in ipairs(surface.find_entities_filtered({ type = SIGNAL_TYPES })) do
      local x, y = sig.position.x - cx, sig.position.y - cy
      if SECTOR[from](x, y) then list[#list + 1] = { name = sig.name, x = x, y = y, d = sig.direction } end
    end
    local removed, made = 0, 0
    for leg, inside in pairs(SECTOR) do
      if leg ~= from then
        for _, sig in ipairs(surface.find_entities_filtered({ type = SIGNAL_TYPES })) do
          if inside(sig.position.x - cx, sig.position.y - cy) then sig.destroy(); removed = removed + 1 end
        end
        local k = (TURN[leg] - TURN[from]) % 4
        for _, s0 in ipairs(list) do
          local x, y = s0.x, s0.y
          for _ = 1, k do x, y = -y, x end
          if set_signal(surface, s0.name, { x + cx, y + cy }, (s0.d + 4 * k) % 16) then made = made + 1 end
        end
      end
    end
    out("copy: %d signals of leg %s turned onto the other legs (%d removed, %d placed)", #list, from, removed, made)
  end
  local area = { { math.min(table.unpack(xs)) - 3, math.min(table.unpack(ys)) - 3 }, { math.max(table.unpack(xs)) + 3, math.max(table.unpack(ys)) + 3 } }
  local inv = game.create_inventory(1)
  inv[1].set_stack({ name = "blueprint" })
  inv[1].create_blueprint({ surface = surface, force = "player", area = area })
  if opts.label then inv[1].label = opts.label end
  if opts.description then inv[1].blueprint_description = opts.description end
  local icons = inv[1].default_icons
  if icons and #icons > 0 then inv[1].preview_icons = icons end
  helpers.write_file("junction-bench/" .. data.name .. ".txt", inv[1].export_stack() .. "\n", false)
  local counts = {}
  for _, ent in ipairs(inv[1].get_blueprint_entities() or {}) do counts[ent.name] = (counts[ent.name] or 0) + 1 end
  local parts = {}
  for k, v in pairs(counts) do parts[#parts + 1] = k .. " " .. v end
  table.sort(parts)
  out("wrote junction-bench/%s.txt: %s", data.name, table.concat(parts, ", "))
  inv.destroy()
end

-- Debug: the signal places of every rail end at the points options.at = {{x, y}, ...}, and the
-- signals near them.
local function ends_mode(surface)
  local function f(l) return l and string.format("%.1f,%.1f/%d", l.position.x, l.position.y, l.direction) or "-" end
  for _, p in ipairs(opts.at or {}) do
    out("point %s,%s", p[1], p[2])
    for _, r in ipairs(rails_of(surface)) do
      for _, dir in ipairs({ RD.front, RD.back }) do
        local re = r.get_rail_end(dir)
        local l = re.location
        if math.abs(l.position.x - p[1]) < 0.01 and math.abs(l.position.y - p[2]) < 0.01 then
          out("  %s at %.1f,%.1f end %d (dir %d): out %s alt-out %s in %s alt-in %s", r.name, r.position.x, r.position.y,
            dir, l.direction, f(re.out_signal_location), f(re.alternative_out_signal_location), f(re.in_signal_location),
            f(re.alternative_in_signal_location))
        end
      end
    end
    for _, sig in ipairs(surface.find_entities_filtered({ area = { { p[1] - 3, p[2] - 3 }, { p[1] + 3, p[2] + 3 } }, type = { "rail-signal", "rail-chain-signal" } })) do
      out("  signal %s %.1f,%.1f dir %d", sig.name, sig.position.x, sig.position.y, sig.direction)
    end
  end
end

script.on_init(function()
  local surface = game.create_surface("junction")
  surface.generate_with_lab_tiles = true
  surface.always_day = true
  local box = build(surface)
  if data.mode == "map" then map_mode(surface, box)
  elseif data.mode == "ends" then ends_mode(surface)
  elseif data.mode == "edit" then
    fill_gaps(surface)
    edit_mode(surface)
  elseif data.mode == "traffic" then
    traffic_setup(surface, box)
    storage.T = T
  end
end)

script.on_load(function() if storage.T then T = storage.T end end)

script.on_event(defines.events.on_tick, function(event)
  if data.mode == "traffic" and T.tracks then traffic_tick(event.tick) end
end)
