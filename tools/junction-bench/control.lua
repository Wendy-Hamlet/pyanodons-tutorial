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
--     options.ahead tiles in front of it are clear. options.lanes: each train goes to a random
--     exit track instead of any of its leg (a test of lane changes). After options.warm minutes it counts,
--     for options.minutes, the trains through per movement, the time from the junction edge until
--     the train has left it, its speed at the edge and the signals trains stand at inside the
--     junction; it reports a deadlock when no train leaves for options.stall seconds.
--   mode "edit": changes the signals (see edit_mode) and writes the junction as a blueprint string.
--   mode "ends": prints the signal places of the rail ends at options.at (for placing signals).
--   mode "run": one train (options.stock, e.g. ["locomotive", "cargo-wagon", "cargo-wagon"]; a
--     name starting with "-" is a locomotive facing backwards) goes round one block of a grid
--     blueprint clockwise on the outer lanes, through rail waypoints in the middle of the four
--     stretches, every fuel slot filled with options.fuel (options.cargo: an item filling every
--     cargo wagon too). Logs speed, distance and fuel every options.every seconds, the speed range
--     of each lap, when and where the fuel ran out and where the train stopped (options.hold: the
--     train first stands that many seconds). Run it for enough ticks (-Ticks) to burn all the fuel.
--   mode "station": builds the whole blueprint (every entity with its settings) around one train
--     stop, extends its two track ends and sends options.trains trains (options.fuel_count fuel,
--     options.ash Ash) from the entrance to the stop with the schedule Cybersyn gives a train it
--     sends to a refueler; logs per train when it stood at the stop, how long, fuel and Ash before
--     and after, and whether it stood wholly in the stop's block. options.feed keeps belts full.
--   mode "build": builds the whole blueprint and reports what could not be built and which
--     electric entities are outside every pole's supply area.
--   mode "network": builds a whole network blueprint (stations of every kind on a grid, built at
--     options.at), powers it and lets Cybersyn run it (see network_setup); options.items fill the
--     blueprint parameters, options.fuels put trains at the depot stops.
--   options.locomotives (default 1) and options.wagons: the trains of modes "traffic" and "station".
-- Results are CF-JUNCTION log lines. Run by tools/junction-bench.ps1, which writes bench-data.lua:
-- the name, the mode, the options and the blueprint's entities as JSON.

local data = require("bench-data")
local opts = helpers.json_to_table(data.options or "{}") or {}
local entities = helpers.json_to_table(data.entities)
local function opt(k, v) if opts[k] == nil then opts[k] = v end end
opt("extend", 320); opt("spacing", 30); opt("clear", 60); opt("warm", 3); opt("minutes", 20)
opt("stall", 120); opt("scenario", "mix"); opt("seed", 1); opt("wagons", 2); opt("fuel", "coal")
opt("locomotive", "locomotive"); opt("wagon", "cargo-wagon"); opt("speed", 0); opt("ahead", 200); opt("source", "lane")
opt("stock", { "locomotive", "cargo-wagon", "cargo-wagon" }); opt("locomotives", 1)
opt("trains", 1); opt("fuel_count", 70); opt("ash", 80)

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
  -- options.entrances = {"W", ...}: the legs trains come in by, for track with no signal to tell.
  if opts.entrances then
    for _, t in ipairs(T.tracks) do
      t.inbound = false
      for _, leg in ipairs(opts.entrances) do if t.leg == leg then t.inbound = true end end
    end
  end
  for _, t in ipairs(T.tracks) do
    local leg = T.legs[t.leg]
    if t.inbound then leg.inn[#leg.inn + 1] = t else leg.out[#leg.out + 1] = t end
    -- Rail signals along the extension, from `spacing` tiles out, facing the way trains run.
    local sx, sy = t.ux, t.uy
    if t.inbound then sx, sy = -sx, -sy end
    -- (options.first: tiles from the track end to the first of them, default the spacing.)
    for k = math.floor((opts.first or opts.spacing) / 2), #t.rails - 2, opts.spacing / 2 do place_signal(surface, t.rails[k], sx, sy) end
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
      -- options.lanes: one stop name per exit track, so trains are sent to a lane, not a leg.
      if t.stop then t.stop.backer_name = "exit " .. t.leg .. (opts.lanes and #leg.out or "") end
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
  local far = t.rails[#t.rails - 6 - 4 * (opts.locomotives - 1 + opts.wagons)]
  local dir = (t.d + 8) % 16
  local stock = {}
  for _ = 1, opts.locomotives do stock[#stock + 1] = opts.locomotive end
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
  local lane = ""
  if opts.lanes then
    T.seed = (T.seed * 1103515245 + 12345) % 2147483648
    lane = math.floor(T.seed / 65536) % #T.legs[to].out + 1
  end
  schedule.add_record({ station = "exit " .. to .. lane })
  schedule.go_to_station(1)
  train.manual_mode = false
  -- Trains arrive at line speed when the track ahead is clear enough to brake on.
  if opts.speed > 0 then
    local k = math.max(1, #t.rails - 6 - 4 * (opts.locomotives - 1 + opts.wagons) - opts.ahead / 2)
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
  -- A leg that got no train through while others did: locked there (the junction as a whole
  -- keeps running, so the deadlock check does not see it).
  local from = {}
  for k, s in pairs(T.stats) do
    local leg = k:match("^(%a+)%->")
    from[leg] = (from[leg] or 0) + s.n
  end
  local dead = {}
  for _, name in ipairs({ "N", "E", "S", "W" }) do
    local leg = T.legs[name]
    if leg and #leg.inn > 0 and not from[name] then dead[#dead + 1] = name end
  end
  if #dead > 0 and total > 0 then out("LOCKED: no train came through from %s", table.concat(dead, ", ")) end
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
  if e.chain_at_switches then
    -- A chain signal before every joint where track splits, joins or crosses, for trains running
    -- the way chain_at_switches names (a direction, 0 = north ... 12 = west): on every rail end
    -- that leaves towards such a joint.
    local tx, ty = unit(e.chain_at_switches)
    local joints = {}
    for _, r in ipairs(rails_of(surface)) do
      for _, dir in ipairs({ RD.front, RD.back }) do
        local l = r.get_rail_end(dir).location
        local key = l.position.x .. "," .. l.position.y
        joints[key] = joints[key] or {}
        table.insert(joints[key], { rail = r, dir = dir, d = l.direction })
      end
    end
    local n = 0
    for _, list in pairs(joints) do
      if #list >= 3 then
        for _, j in ipairs(list) do
          local ux, uy = unit(j.d)
          if ux * tx + uy * ty > 0 then
            local l = j.rail.get_rail_end(j.dir).out_signal_location
            if l and #surface.find_entities_filtered({ position = l.position, type = SIGNAL_TYPES }) == 0 then
              if surface.create_entity({ name = "rail-chain-signal", position = l.position, direction = l.direction, force = "player" }) then n = n + 1 end
            end
          end
        end
      end
    end
    out("chain_at_switches: %d chain signals placed", n)
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

-- ---------- run ----------

-- One train round one block of a grid blueprint (see the header). The outer lane of clockwise
-- travel is the lane of each road nearest the block's middle.
local R = {}

local function run_setup(surface, box)
  local mx, my = (box.x1 + box.x2) / 2, (box.y1 + box.y2) / 2
  local function lane(area, key, pick)
    local best
    for _, r in ipairs(surface.find_entities_filtered({ area = area, name = "straight-rail" })) do
      if not best or pick(r.position[key], best.position[key]) then best = r end
    end
    return best
  end
  local gt, lt = function(a, b) return a > b end, function(a, b) return a < b end
  local north = lane({ { mx - 1, box.y1 }, { mx + 1, my } }, "y", gt)
  local east = lane({ { mx, my - 1 }, { box.x2, my + 1 } }, "x", lt)
  local south = lane({ { mx - 1, my }, { mx + 1, box.y2 } }, "y", lt)
  local west = lane({ { box.x1, my - 1 }, { mx, my + 1 } }, "x", gt)
  if not (north and east and south and west) then error("no block found") end
  out("waypoints N %.1f,%.1f E %.1f,%.1f S %.1f,%.1f W %.1f,%.1f", north.position.x, north.position.y,
    east.position.x, east.position.y, south.position.x, south.position.y, west.position.x, west.position.y)
  -- Locomotive first, heading east on the north road; "-name" is a locomotive facing backwards.
  local x, y = north.position.x + 20, north.position.y
  local cars, prev = {}, nil
  for _, s in ipairs(opts.stock) do
    local back = s:sub(1, 1) == "-"
    local name = back and s:sub(2) or s
    if prev then x = x - gap(prev, name) end
    prev = name
    local c = surface.create_entity({ name = name, position = { x, y }, force = "player",
      direction = back and defines.direction.west or defines.direction.east })
    if not c then error("could not place " .. name .. " at " .. x .. "," .. y) end
    cars[#cars + 1] = c
  end
  local train = cars[1].train
  if #train.carriages ~= #cars then error("cars did not couple: " .. #train.carriages .. " of " .. #cars) end
  local energy = 0
  for _, c in ipairs(cars) do
    if c.type == "locomotive" then
      local inv = c.get_fuel_inventory()
      local item = prototypes.item[opts.fuel]
      local n = inv.insert({ name = opts.fuel, count = item.stack_size * #inv })
      energy = energy + n * item.fuel_value
    elseif c.type == "cargo-wagon" and opts.cargo then
      local inv = c.get_inventory(defines.inventory.cargo_wagon)
      inv.insert({ name = opts.cargo, count = prototypes.item[opts.cargo].stack_size * #inv })
    end
  end
  local schedule = train.get_schedule()
  for _, r in ipairs({ east, south, west, north }) do schedule.add_record({ rail = r }) end
  schedule.go_to_station(1)
  train.manual_mode = (opts.hold or 0) > 0
  out("train %s: %d cars, weight %.0f, fuel %.0f MJ (%s), cargo %s", table.concat(opts.stock, " "), #cars,
    train.weight, energy / 1e6, opts.fuel, opts.cargo or "none")
  local front = train.front_stock.position
  R = { train = train, locos = {}, dist = 0, lap = 0, lap_max = 0, lap_min = math.huge, top = 0,
    x = front.x + 1, y = front.y, last_x = front.x, every = (opts.every or 10) * 60 }
  for _, c in ipairs(cars) do if c.type == "locomotive" then R.locos[#R.locos + 1] = c end end
  storage.R = R
end

local function fuel_left()
  local e = 0
  for _, c in ipairs(R.locos) do
    e = e + c.burner.remaining_burning_fuel
    for _, s in pairs(c.get_fuel_inventory().get_contents()) do e = e + s.count * prototypes.item[s.name].fuel_value end
  end
  return e
end

local function run_tick(tick)
  if R.stopped then return end
  -- options.hold: seconds the train first stands in manual mode (does a standing train burn fuel?).
  if opts.hold and tick == opts.hold * 60 then R.train.manual_mode = false end
  local t = R.train
  local v = math.abs(t.speed)
  R.dist = R.dist + v
  local kmh = v * 216
  if kmh > R.top then R.top = kmh end
  if tick > 600 and not R.out then
    R.lap_max = math.max(R.lap_max, kmh)
    R.lap_min = math.min(R.lap_min, kmh)
  end
  -- A lap ends when the front passes the start point on the north road again.
  local front = t.front_stock.position
  if math.abs(front.y - R.y) < 3 and R.last_x < R.x and front.x >= R.x then
    R.lap = R.lap + 1
    out("lap %d at %.0f s: %.0f tiles, speed %.0f-%.0f km/h", R.lap, tick / 60, R.dist, R.lap_min, R.lap_max)
    R.lap_max, R.lap_min = 0, math.huge
  end
  R.last_x = front.x
  local left = fuel_left()
  if not R.out and left == 0 then
    R.out = { tick = tick, dist = R.dist, kmh = kmh }
    out("fuel out at %.0f s: %.0f tiles, speed %.0f km/h", tick / 60, R.dist, kmh)
  end
  if tick % R.every == 0 then
    out("t %4.0f s  speed %5.1f km/h  distance %7.0f tiles  fuel %6.1f MJ  state %d", tick / 60, kmh, R.dist,
      left / 1e6, t.state)
  end
  if R.out and v < 1e-4 then
    R.stopped = true
    out("stopped at %.0f s: %.0f tiles (%.0f coasting); top speed %.1f km/h", tick / 60, R.dist, R.dist - R.out.dist, R.top)
  end
end

-- ---------- station ----------

-- The whole blueprint, every entity with its settings, through a blueprint item; ghosts revived.
local S = {}

local function build_all(surface)
  local c = opts.chunks or 8
  for cx = -c, c do
    for cy = -c, c do surface.request_to_generate_chunks({ cx * 32, cy * 32 }, 0) end
  end
  surface.force_generate_chunk_requests()
  local inv = game.create_inventory(1)
  inv[1].set_stack({ name = "blueprint" })
  local r = inv[1].import_stack(data.blueprint)
  if r ~= 0 then out("import_stack returned %d", r) end
  local want = {}
  for _, e in pairs(inv[1].get_blueprint_entities() or {}) do want[e.name] = (want[e.name] or 0) + 1 end
  local ghosts = inv[1].build_blueprint({ surface = surface, force = "player", position = opts.at or { 0, 0 },
    build_mode = defines.build_mode.forced })
  local n, got, unpowered, built = 0, {}, {}, {}
  for _, g in pairs(ghosts) do
    if g.valid and g.type == "entity-ghost" then
      local name, pos = g.ghost_name, g.position
      local _, e = g.silent_revive({ raise_revive = true })
      if e then
        n = n + 1
        got[e.name] = (got[e.name] or 0) + 1
        built[#built + 1] = e
      elseif opts.list_failed then
        out("not built: %s at %.1f,%.1f", name, pos.x, pos.y)
      end
    end
  end
  inv.destroy()
  -- Checked once everything stands: a pole built later still powers what came before it.
  for _, e in ipairs(built) do
    -- (electric_network_id: in some pole's supply area; the lab has nothing that makes power.)
    if e.valid and e.prototype.electric_energy_source_prototype and not e.electric_network_id then
      unpowered[#unpowered + 1] = string.format("%s@%.1f,%.1f", e.name, e.position.x, e.position.y)
    end
  end
  local missing = {}
  for name, k in pairs(want) do
    if (got[name] or 0) < k then missing[#missing + 1] = string.format("%s %d of %d", name, got[name] or 0, k) end
  end
  table.sort(missing)
  out("built %d entities%s; outside any pole's supply area: %s", n,
    #missing > 0 and ("; not built: " .. table.concat(missing, ", ")) or "",
    #unpowered > 0 and table.concat(unpowered, " ") or "none")
end

local function fuel_of(train)
  local fuel, ash = 0, 0
  for _, c in ipairs(train.carriages) do
    if c.type == "locomotive" then
      fuel = fuel + c.get_fuel_inventory().get_item_count()
      ash = ash + c.get_burnt_result_inventory().get_item_count()
    end
  end
  return fuel, ash
end

local function cargo_of(train)
  local n = 0
  for _, w in pairs(train.cargo_wagons) do n = n + w.get_inventory(defines.inventory.cargo_wagon).get_item_count() end
  for _, v in pairs(train.get_fluid_contents()) do n = n + v end
  return math.floor(n)
end

local function station_setup(surface)
  build_all(surface)
  -- One train stop, or several of one name (a depot); options.limit overrides their train limits.
  local stops = surface.find_entities_filtered({ type = "train-stop" })
  if #stops == 0 then error("no train stop") end
  local stop = stops[1]
  for _, s in ipairs(stops) do
    if s.backer_name ~= stop.backer_name then error("train stops of different names") end
    if opts.limit then s.trains_limit = opts.limit end
    out("train stop %q at %.1f,%.1f, train limit %s", s.backer_name, s.position.x, s.position.y,
      s.trains_limit < 4e9 and s.trains_limit or "none")
  end
  if stop.backer_name == "" then stop.backer_name = "station" end
  S.stop, S.stops = stop, {}
  for _, s in ipairs(stops) do S.stops[s.unit_number] = s end
  -- The entrance and exit: the station's two open track ends, or, with options.entrance_at and
  -- options.exit_at ({dx, dy} from the train stops' middle), the track ends nearest those points.
  local ends = track_ends(rails_of(surface))
  local cx, cy = 0, 0
  for _, s in ipairs(stops) do cx, cy = cx + s.position.x / #stops, cy + s.position.y / #stops end
  local function nearest(at)
    local best, bd
    for _, e in ipairs(ends) do
      local d = (e.x - cx - at[1]) ^ 2 + (e.y - cy - at[2]) ^ 2
      if not bd or d < bd then best, bd = e, d end
    end
    return best
  end
  if opts.entrance_at then ends = { nearest(opts.entrance_at), nearest(opts.exit_at) } end
  for _, e in ipairs(ends) do
    local ux, uy = unit(e.d)
    local rails = extend(surface, e, opts.extend)
    local far = rails[#rails]
    local inbound = e == ends[1] and opts.entrance_at ~= nil
    if not opts.entrance_at then
      inbound = game.train_manager.request_train_path({ type = "any-goal-accessible",
        starts = { { rail = far, direction = end_facing(far, -ux, -uy) } }, goals = stops }).found_path
    end
    local t = { ux = ux, uy = uy, rails = rails, d = e.d }
    -- Rail signals along the extension, facing the way trains run.
    local sx, sy = ux, uy
    if inbound then sx, sy = -sx, -sy; S.inn = t else S.exit = t end
    for k = math.floor(opts.spacing / 2), #rails - 2, opts.spacing / 2 do place_signal(surface, rails[k], sx, sy) end
  end
  if not (S.inn and S.exit) then error("no entrance or no exit") end
  -- options.trains trains queue on the entrance track, each with options.fuel_count fuel and
  -- options.ash Ash; they get the schedule Cybersyn gives a train it sends to a refueler: a rail
  -- record on the stop's own rail (1 tick), the stop (100 ticks of inactivity), then the exit.
  -- options.depot: instead the schedule Cybersyn gives a train at its depot, the stop's name with
  -- 100 ticks of inactivity as its only record: the trains park and stay.
  -- options.through more trains queue behind them and only pass by, to the exit.
  S.trains = {}
  local t = S.inn
  local cars = opts.locomotives + opts.wagons
  local total = opts.trains + (opts.through or 0)
  for i = 1, total do
    local k = #t.rails - 6 - 4 * (cars - 1) - (total - i) * (opts.spacing / 2)
    if k < 2 then error("entrance track too short") end
    local far = t.rails[k]
    local x, y = far.position.x, far.position.y
    local stock = {}
    for _ = 1, opts.locomotives do stock[#stock + 1] = opts.locomotive end
    for _ = 1, opts.wagons do stock[#stock + 1] = opts.wagon end
    local made = {}
    for j, name in ipairs(stock) do
      if j > 1 then local g = gap(stock[j - 1], name); x, y = x + t.ux * g, y + t.uy * g end
      local c = surface.create_entity({ name = name, position = { x, y }, direction = (t.d + 8) % 16, force = "player" })
      if not c then error("could not place " .. name) end
      made[#made + 1] = c
      if c.type == "locomotive" then
        c.get_fuel_inventory().insert({ name = opts.fuel, count = opts.fuel_count })
        if opts.ash > 0 then c.get_burnt_result_inventory().insert({ name = "ash", count = opts.ash }) end
      end
    end
    local train = made[1].train
    local schedule = train.get_schedule()
    -- i counts from the train nearest the station; the through trains come last.
    local through = i > opts.trains
    if through then
      schedule.add_record({ rail = S.exit.rails[#S.exit.rails] })
    elseif opts.depot then
      schedule.add_record({ station = stop.backer_name,
        wait_conditions = { { type = "inactivity", compare_type = "and", ticks = 100 } } })
    else
      -- options.load = {item, count, circuit}: Cybersyn's loading order at a provider instead
      -- (wait until the train holds count items; with circuit, also until the stop sends
      -- signal-check > 0, the station's "circuit condition" setting).
      local wait = { { type = "inactivity", compare_type = "and", ticks = 100 } }
      if opts.load then
        wait = { { type = "item_count", compare_type = "and", condition = { comparator = "≥",
          first_signal = { type = "item", name = opts.load.item }, constant = opts.load.count } } }
        if opts.load.circuit then
          wait[2] = { type = "circuit", compare_type = "and", condition = { comparator = ">",
            first_signal = { type = "virtual", name = "signal-check" }, constant = 0 } }
        end
      end
      schedule.add_record({ rail = stop.connected_rail, rail_direction = stop.connected_rail_direction, temporary = true,
        wait_conditions = { { type = "time", compare_type = "and", ticks = 1 } } })
      schedule.add_record({ station = stop.backer_name, temporary = true, wait_conditions = wait })
      schedule.add_record({ rail = S.exit.rails[#S.exit.rails] })
    end
    schedule.go_to_station(1)
    train.manual_mode = false
    S.trains[#S.trains + 1] = { train = train, n = i, through = through }
  end
  out("%d trains of %d locomotive(s) + %d wagon(s), each with %d %s and %d Ash", #S.trains, opts.locomotives,
    opts.wagons, opts.fuel_count, opts.fuel, opts.ash)
  storage.S = S
end

local function station_tick(tick)
  -- options.feed = {{item, at = {dx, dy}}}: a belt kept full, placed relative to the train stop.
  for _, f in ipairs(opts.feed or {}) do
    local p = { S.stop.position.x + f.at[1], S.stop.position.y + f.at[2] }
    local belt = S.stop.surface.find_entities_filtered({ position = p, type = "transport-belt" })[1]
    if belt then
      for line = 1, 2 do belt.get_transport_line(line).insert_at_back({ name = f.item }) end
    elseif tick == 1 then out("no belt at %.1f,%.1f", p[1], p[2]) end
  end
  local exit_far = S.exit.rails[#S.exit.rails].position
  for _, t in ipairs(S.trains) do
    local train = t.train
    if train.valid and not t.gone then
      local st = train.station
      local at = st and S.stops[st.unit_number] and train.state == defines.train_state.wait_station
      if at and not t.arrived then
        t.arrived = tick
        t.fuel0, t.ash0 = fuel_of(train)
        -- Does the whole train stand in the stop's block (so the next one can come up behind)?
        local inside = true
        for _, r in pairs(train.get_rails()) do
          if not r.is_rail_in_same_rail_block_as(st.connected_rail) then inside = false end
        end
        t.inside = inside
        if opts.depot then
          out("train %d parked at the stop at %.1f,%.1f after %.1f s; %s", t.n, st.position.x, st.position.y,
            tick / 60, inside and "wholly in the stop's block" or "NOT wholly in the stop's block")
        end
      elseif t.arrived and not t.left and not at then
        t.left = tick
        local fuel, ash = fuel_of(train)
        out("train %d: at the stop %.1f s after the start, stood %.1f s; fuel %d -> %d, Ash %d -> %d, cargo %d; %s", t.n,
          t.arrived / 60, (tick - t.arrived) / 60, t.fuel0, fuel, t.ash0, ash, cargo_of(train),
          t.inside and "wholly in the stop's block" or "NOT wholly in the stop's block")
        S.done = (S.done or 0) + 1
        S.served = (S.served or 0) + 1
        S.first = S.first or t.arrived
        S.last = tick
      end
      local front = train.front_stock.position
      if (t.left or t.through) and (front.x - exit_far.x) ^ 2 + (front.y - exit_far.y) ^ 2 < 40 ^ 2 then
        if t.through then
          out("through train %d reached the exit after %.1f s", t.n, tick / 60)
          S.done = (S.done or 0) + 1
        end
        for _, c in pairs(train.carriages) do c.destroy() end
        t.gone = true
      end
    end
  end
  if not S.reported and S.done == #S.trains then
    S.reported = true
    local n = S.served or 0
    out("%d trains served in %.1f s (first arrival to last departure): %.1f trains a minute", n,
      n > 0 and (S.last - S.first) / 60 or 0, n > 1 and (n - 1) / ((S.last - S.first) / 3600) or 0)
  end
  if tick % 3600 == 0 and (not S.reported or opts.depot) then
    local parts = {}
    for _, t in ipairs(S.trains) do
      if t.train.valid and not t.gone then
        local p = t.train.front_stock.position
        -- A waiting train standing in more than one block is marked "across blocks".
        local front, across = t.train.front_end and t.train.front_end.rail, false
        if front then
          for _, r in pairs(t.train.get_rails()) do
            if not r.is_rail_in_same_rail_block_as(front) then across = true end
          end
        end
        parts[#parts + 1] = string.format("%d@%.0f,%.0f/%s%s", t.n, p.x, p.y,
          t.arrived and string.format("at the stop, cargo %d", cargo_of(t.train)) or t.train.state,
          across and " across blocks" or "")
      end
    end
    out("t %d s: %s", tick / 60, table.concat(parts, " "))
  end
end

-- ---------- network ----------

-- Cybersyn itself runs a whole network: the blueprint holds stations of every kind on a grid. It is
-- built with every setting and powered, the blueprint parameters are filled in, the providers' chests
-- and tanks and the refuelers' fuel chests are filled, and trains are put at the depot stops.
local N = {}
local STATUS = { [0] = "at depot", "to provider", "at provider", "to requester", "at requester", "to depot",
  "to depot (bypass)", "to refueler", "at refueler" }
local MODE = { ["/"] = "station", ["+"] = "depot", [">>"] = "refueler" }
local PR = { [0] = "provide+request", "provide only", "request only", "?" }

-- Every entity on the circuit networks of the given wire connectors of an entity.
local function wired(entity, ids)
  local found, seen, queue = {}, {}, {}
  for _, id in ipairs(ids) do
    local c = entity.get_wire_connector(id, false)
    if c then queue[#queue + 1] = c end
  end
  while #queue > 0 do
    local c = table.remove(queue)
    for _, conn in pairs(c.connections) do
      local t = conn.target
      local key = t.owner.unit_number .. ":" .. t.wire_connector_id
      if not seen[key] then
        seen[key] = true
        if t.owner ~= entity then found[t.owner.unit_number] = t.owner end
        queue[#queue + 1] = t
      end
    end
  end
  return found
end

local IN = { defines.wire_connector_id.combinator_input_red, defines.wire_connector_id.combinator_input_green }

-- options.items[k + 1] stands for parameter-k (an item or a fluid) and options.amount, if set, for every request.
local function resolve(s)
  return (s:gsub("%[item=parameter%-(%d)%]", function(k)
    local name = (opts.items or {})[tonumber(k) + 1]
    if not name then return nil end
    return "[" .. (prototypes.fluid[name] and "fluid" or "item") .. "=" .. name .. "]"
  end):gsub("^parameter%-(%d)$", function(k) return (opts.items or {})[tonumber(k) + 1] end))
end

local function is_store(e) return e.type == "container" or e.type == "storage-tank" end

-- The wired tanks of a station in a fixed order.
local function tanks_of(st)
  local tanks = {}
  for _, c in pairs(st.chests) do if c.valid and c.type == "storage-tank" then tanks[#tanks + 1] = c end end
  table.sort(tanks, function(a, b) return a.position.x + a.position.y < b.position.x + b.position.y end)
  return tanks
end

local function chest_total(chests)
  local n, k = 0, 0
  for _, c in pairs(chests) do
    if c.type == "container" then n, k = n + c.get_inventory(defines.inventory.chest).get_item_count(), k + 1
    elseif c.type == "storage-tank" then n, k = n + c.get_fluid_count(), k + 1 end
  end
  return math.floor(n), k
end

-- On the road: within 13 tiles of a grid line (the grid's tracks and the stations' switches).
local function on_road(p)
  local function near(v) local m = v % 240; return m <= 13 or m >= 227 end
  return near(p.x) or near(p.y)
end

local function network_setup(surface)
  build_all(surface)
  -- Power: one energy interface, wired to one pole of every separate pole network.
  local at = opts.power_at or { -150, -150 }
  local eei = surface.create_entity({ name = "electric-energy-interface", position = at, force = "player" })
  eei.power_production, eei.electric_buffer_size = 1e8, 1e9
  local hub = surface.create_entity({ name = "small-electric-pole", position = { at[1] + 2, at[2] }, force = "player" })
  local hc = hub.get_wire_connector(defines.wire_connector_id.pole_copper, true)
  local joined = 0
  for _, p in pairs(surface.find_entities_filtered({ type = "electric-pole" })) do
    if p.electric_network_id ~= hub.electric_network_id then
      p.get_wire_connector(defines.wire_connector_id.pole_copper, true).connect_to(hc, false)
      joined = joined + 1
    end
  end
  out("power: %d separate pole network(s) wired to an energy interface", joined)
  -- Blueprint parameters: stop names and constant combinators.
  for _, s in pairs(surface.find_entities_filtered({ type = "train-stop" })) do s.backer_name = resolve(s.backer_name) end
  for _, c in pairs(surface.find_entities_filtered({ name = "constant-combinator" })) do
    for _, sec in pairs(c.get_control_behavior().sections) do
      for i = 1, sec.filters_count do
        local f = sec.get_slot(i)
        if f.value and f.value.name and f.value.name:match("^parameter%-%d$") then
          local name = resolve(f.value.name)
          sec.set_slot(i, { value = { type = prototypes.fluid[name] and "fluid" or "item", name = name, quality = "normal", comparator = "=" },
            min = opts.amount and -opts.amount or f.min })
        end
      end
    end
  end
  -- Each Cybernetic combinator: its mode, its stop, what it reads; providers' chests filled.
  N.stations, N.depots, N.fuel_chests = {}, {}, {}
  for _, comb in pairs(surface.find_entities_filtered({ name = "cybersyn-combinator" })) do
    local p = comb.get_control_behavior().parameters
    local stop = surface.find_entities_filtered({ type = "train-stop", position = comb.position, radius = 3 })[1]
    local mode = MODE[p.operation] or p.operation
    local bits = p.second_constant or 0
    local chests = wired(comb, IN)
    local nchest, nconst = 0, 0
    for _, e in pairs(chests) do
      if is_store(e) then nchest = nchest + 1 elseif e.type == "constant-combinator" then nconst = nconst + 1 end
    end
    local name = stop and stop.backer_name or "?"
    out("%s %q at %.1f,%.1f: %s, train limit %s, wired to %d chest(s) and %d constant combinator(s)", mode, name,
      stop and stop.position.x or 0, stop and stop.position.y or 0, mode == "station" and PR[bits % 4] or "-",
      stop and (stop.trains_limit < 4e9 and stop.trains_limit or "none") or "-", nchest, nconst)
    if mode == "station" then
      local item = name:match("%[item=([^%]]+)%]")
      local fluid = name:match("%[fluid=([^%]]+)%]")
      N.stations[#N.stations + 1] = { stop = stop, comb = comb, chests = chests, name = name, item = item, fluid = fluid }
      if bits % 4 == 1 and (item or fluid) and opts.stock and nchest > 0 then
        local each = math.ceil(opts.stock / nchest)
        for _, e in pairs(chests) do
          if e.type == "container" and item then e.insert({ name = item, count = each }) end
        end
        -- options.feed_one: a production line piped to one tank only.
        local tanks = fluid and tanks_of(N.stations[#N.stations]) or {}
        for i, e in ipairs(tanks) do
          if i == 1 or not opts.feed_one then e.insert_fluid({ name = fluid, amount = each }) end
        end
      end
    elseif mode == "depot" and stop then
      N.depots[#N.depots + 1] = stop
    elseif mode == "refueler" and stop then
      -- Fuel chests: those no filtered (Ash) inserter drops into.
      local ash = {}
      for _, i in pairs(surface.find_entities_filtered({ type = "inserter", position = stop.position, radius = 16 })) do
        if i.use_filters and i.drop_target then ash[i.drop_target.unit_number] = true end
      end
      for _, c in pairs(surface.find_entities_filtered({ type = "container", position = stop.position, radius = 14 })) do
        if not ash[c.unit_number] then
          c.insert({ name = opts.fuel, count = opts.refuel_stock or 1000 })
          N.fuel_chests[#N.fuel_chests + 1] = c
        end
      end
    end
  end
  -- Trains: one per entry of options.fuels (its fuel count), put just before a depot stop with
  -- Cybersyn's depot schedule.
  table.sort(N.depots, function(a, b) return a.position.x + a.position.y * 1e4 < b.position.x + b.position.y * 1e4 end)
  N.trains = {}
  for i, fuel in ipairs(opts.fuels or {}) do
    local stop = N.depots[i]
    if not stop then error("more trains than depot stops") end
    local ux, uy = unit(stop.direction)
    -- A stop stands 2 tiles to the right of its track.
    local x, y = stop.position.x + 2 * uy - ux * 5.5, stop.position.y - 2 * ux - uy * 5.5
    -- options.fluid_trains: the last n trains have fluid wagons.
    local wagon = (opts.fluid_trains and i > #opts.fuels - opts.fluid_trains) and "fluid-wagon" or opts.wagon
    local stock = { opts.locomotive }
    for _ = 1, opts.wagons do stock[#stock + 1] = wagon end
    local made = {}
    for j, name in ipairs(stock) do
      -- (from the car before as it was placed: the game moves rolling stock onto the rail)
      if j > 1 then
        local g, prev = gap(stock[j - 1], name), made[j - 1].position
        x, y = prev.x - ux * g, prev.y - uy * g
      end
      local c = surface.create_entity({ name = name, position = { x, y }, direction = stop.direction, force = "player" })
      if not c then error("could not place " .. name .. " at depot stop " .. i) end
      made[#made + 1] = c
    end
    made[1].get_fuel_inventory().insert({ name = opts.fuel, count = fuel })
    local train = made[1].train
    if #train.carriages ~= #stock then error("cars did not couple at depot stop " .. i) end
    local schedule = train.get_schedule()
    schedule.add_record({ station = stop.backer_name,
      wait_conditions = { { type = "inactivity", compare_type = "and", ticks = 100 } } })
    schedule.go_to_station(1)
    train.manual_mode = false
    N.trains[#N.trains + 1] = { train = train, n = i }
  end
  out("%d trains of 1 %s + %d %s (the last %d with fluid wagons), fuel %s %s", #N.trains, opts.locomotive, opts.wagons, opts.wagon,
    opts.fluid_trains or 0, table.concat(opts.fuels or {}, "/"), opts.fuel)
  N.status, N.visit, N.done = {}, {}, {}
  storage.N = N
end

local function network_tick(tick)
  if tick % 60 ~= 0 then return end
  local now = tick / 60
  -- options.restock: the providers' stores are topped up and the requesters' emptied every 10 s, as
  -- if belts or pipes kept feeding the one and a factory used up the other. restock = "provider": only
  -- the providers, the requesters keep what they get.
  if opts.restock and tick % 600 == 0 then
    for _, st in ipairs(N.stations) do
      local p = st.comb.get_control_behavior().parameters.second_constant % 4
      if p == 1 and st.fluid then
        for i, c in ipairs(tanks_of(st)) do
          if i == 1 or not opts.feed_one then c.insert_fluid({ name = st.fluid, amount = 1e7 }) end
        end
      end
      for _, c in pairs(st.chests) do
        if c.valid and is_store(c) then
          if p == 1 then
            if st.item and c.type == "container" then c.insert({ name = st.item, count = 1e6 }) end
          elseif opts.restock ~= "provider" then
            if c.type == "container" then c.clear_items_inside() else c.clear_fluid_inside() end
          end
        end
      end
    end
    for _, c in ipairs(N.fuel_chests) do if c.valid then c.insert({ name = opts.fuel, count = 1e6 }) end end
  end
  -- options.drain: a factory using this many fluid units or items a second at each requester's platform,
  -- from all its tanks or chests; options.drain_one: from one tank only (a factory piped to that tank).
  -- st.dry counts the seconds such a factory found its store empty.
  if opts.drain then
    for _, st in ipairs(N.stations) do
      if st.comb.get_control_behavior().parameters.second_constant % 4 ~= 1 then
        if st.fluid then
          local tanks = tanks_of(st)
          if opts.drain_one then
            tanks[1].extract_fluid({ name = st.fluid, amount = opts.drain })
          else
            for _, c in ipairs(tanks) do c.extract_fluid({ name = st.fluid, amount = opts.drain / #tanks }) end
          end
        elseif st.item then
          local left = opts.drain
          for _, c in pairs(st.chests) do
            if left > 0 and c.valid and c.type == "container" then
              left = left - c.get_inventory(defines.inventory.chest).remove({ name = st.item, count = left })
            end
          end
          if left > 0 then st.dry = (st.dry or 0) + 1 end
        end
      end
    end
  end
  local ct = remote.call("cybersyn", "read_global", "trains") or {}
  local cs = remote.call("cybersyn", "read_global", "stations") or {}
  local function sname(id) local s = id and cs[id]; return s and s.entity_stop and s.entity_stop.valid and s.entity_stop.backer_name or "-" end
  for id, t in pairs(ct) do
    if N.status[id] ~= t.status then
      local extra = ""
      if t.status == 1 and t.manifest then
        local m = {}
        for _, e in ipairs(t.manifest) do m[#m + 1] = e.count .. " " .. e.name end
        extra = string.format(": %s from %s to %s", table.concat(m, ", "), sname(t.p_station_id), sname(t.r_station_id))
      end
      out("t %5.0f s  train %d: %s%s", now, t.entity and t.entity.valid and t.entity.id or id, STATUS[t.status] or t.status, extra)
      N.status[id] = t.status
      if t.status == 4 then N.done.deliveries = (N.done.deliveries or 0) + 1 end
    end
  end
  -- Every stop visit: how long, cargo and fuel before and after.
  for _, train in pairs(game.train_manager.get_trains({ surface = "junction" })) do
    local v = N.visit[train.id]
    local at = train.state == defines.train_state.wait_station and train.station
    if at and not v then
      local fuel = fuel_of(train)
      N.visit[train.id] = { stop = at.backer_name, t = tick, cargo = cargo_of(train), fuel = fuel }
    elseif v and not at then
      local fuel = fuel_of(train)
      out("t %5.0f s  train %d stood %.1f s at %s: cargo %d -> %d, fuel %d -> %d", now, train.id, (tick - v.t) / 60, v.stop,
        v.cargo, cargo_of(train), v.fuel, fuel)
      N.visit[train.id] = nil
    end
  end
  if tick % (60 * (opts.every or 60)) == 0 then
    -- Trains not moving, and whether they stand on a road.
    local parts = {}
    local names = {}
    for k, v in pairs(defines.train_state) do names[v] = k end
    for _, train in pairs(game.train_manager.get_trains({ surface = "junction" })) do
      local s = train.state
      if s ~= defines.train_state.on_the_path and s ~= defines.train_state.wait_station
        and s ~= defines.train_state.arrive_station and s ~= defines.train_state.arrive_signal then
        local road, across = false, false
        local front = train.front_end and train.front_end.rail
        for _, r in pairs(train.get_rails()) do
          if on_road(r.position) then road = true end
          if front and not r.is_rail_in_same_rail_block_as(front) then across = true end
        end
        local p, sg = train.front_stock.position, train.signal
        parts[#parts + 1] = string.format("%d@%.0f,%.0f %s%s%s%s", train.id, p.x, p.y, names[s] or s,
          sg and string.format(" at signal %.1f,%.1f", sg.position.x, sg.position.y) or "",
          across and " across blocks" or "", road and " ON THE ROAD" or "")
      end
    end
    out("t %5.0f s  waiting: %s", now, #parts > 0 and table.concat(parts, " ") or "none")
    for _, st in ipairs(N.stations) do
      local n, k = chest_total(st.chests)
      local c = nil
      for _, s in pairs(cs) do
        if s.entity_stop and s.entity_stop.valid and s.entity_stop.unit_number == st.stop.unit_number then c = s end
      end
      out("t %5.0f s  %s: %d items in %d wired chests; Cybersyn: %s%s", now, st.name, n, k,
        c and string.format("%s%s, %d deliveries under way, display %d", c.is_p and "p" or "", c.is_r and "r" or "",
          c.deliveries_total, c.display_state) or "not registered",
        st.dry and string.format("; dry %d s so far", st.dry) or "")
    end
  end
end

script.on_init(function()
  local surface = game.create_surface("junction")
  surface.generate_with_lab_tiles = true
  surface.always_day = true
  if data.mode == "station" then station_setup(surface); return end
  if data.mode == "build" then build_all(surface); return end
  if data.mode == "network" then network_setup(surface); return end
  local box = build(surface)
  if data.mode == "map" then map_mode(surface, box)
  elseif data.mode == "ends" then ends_mode(surface)
  elseif data.mode == "edit" then
    fill_gaps(surface)
    edit_mode(surface)
  elseif data.mode == "traffic" then
    traffic_setup(surface, box)
    storage.T = T
  elseif data.mode == "run" then
    run_setup(surface, box)
  end
end)

script.on_load(function()
  if storage.T then T = storage.T end
  if storage.R then R = storage.R end
  if storage.S then S = storage.S end
  if storage.N then N = storage.N end
end)

script.on_event(defines.events.on_tick, function(event)
  if data.mode == "traffic" and T.tracks then traffic_tick(event.tick) end
  if data.mode == "run" and R.train then run_tick(event.tick) end
  if data.mode == "station" and S.trains then station_tick(event.tick) end
  if data.mode == "network" and N.trains then network_tick(event.tick) end
end)
