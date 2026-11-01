-- Reads, one tick after a copy of a save loads (tools/save-probe.ps1), every train and train stop:
-- for a train its cars, state, manual or automatic, schedule (records with their wait
-- conditions, the current one marked), fuel and burnt results of each locomotive and the cargo;
-- for a stop its name, place, train limit and the trains bound for it; whether each train can
-- reach each stop; ghosts of stops and combinators; and what Cybersyn holds: depots, refuelers,
-- stations with what their combinators read, machines around them, its trains. Nothing in the
-- base is changed.
-- Variant: N, ticks after which the stations are read once more (use -Ticks above N).

local ok, variant = pcall(require, "variant")
local again = ok and tonumber(variant)

local function out(fmt, ...) log("CF-TRAINS " .. string.format(fmt, ...)) end

local STATE = {}
for k, v in pairs(defines.train_state) do STATE[v] = k end

local function contents(inv)
  local parts = {}
  for _, s in pairs(inv and inv.get_contents() or {}) do parts[#parts + 1] = s.count .. " " .. s.name end
  return #parts > 0 and table.concat(parts, ", ") or "empty"
end

local function wait(c)
  local p = c.type
  if c.ticks then p = p .. " " .. c.ticks .. " ticks" end
  if c.condition and c.condition.first_signal then
    p = p .. " " .. (c.condition.first_signal.name or "?") .. " " .. (c.condition.comparator or "") .. " " .. tostring(c.condition.constant)
  end
  return p
end

local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end

local function station_signals()
  for id, s in pairs(remote.call("cybersyn", "read_global", "stations") or {}) do
    local parts = {}
    for _, v in pairs(s.entity_comb1.get_signals(defines.wire_connector_id.combinator_input_red,
      defines.wire_connector_id.combinator_input_green) or {}) do
      parts[#parts + 1] = string.format("%s %d", v.signal.name, v.count)
    end
    out("station %d at tick %d: combinator %s, reads: %s", id, game.tick, STATUS[s.entity_comb1.status] or tostring(s.entity_comb1.status),
      #parts > 0 and table.concat(parts, ", ") or "nothing")
  end
end

script.on_event(defines.events.on_tick, function()
  script.on_event(defines.events.on_tick, nil)
  local surface = game.surfaces.nauvis
  for _, t in pairs(game.train_manager.get_trains({ surface = surface })) do
    local cars = {}
    for _, c in ipairs(t.carriages) do cars[#cars + 1] = c.name end
    local front = t.front_stock.position
    out("train %d at %.1f,%.1f: %s; %s, %s, speed %.1f km/h", t.id, front.x, front.y, table.concat(cars, " + "),
      STATE[t.state] or tostring(t.state), t.manual_mode and "manual" or "automatic", t.speed * 216)
    for _, loco in ipairs(t.locomotives.front_movers) do
      out("  locomotive %.1f,%.1f facing forward: fuel %s; burnt %s", loco.position.x, loco.position.y,
        contents(loco.get_fuel_inventory()), contents(loco.get_burnt_result_inventory()))
    end
    for _, loco in ipairs(t.locomotives.back_movers) do
      out("  locomotive %.1f,%.1f facing back: fuel %s", loco.position.x, loco.position.y, contents(loco.get_fuel_inventory()))
    end
    for _, w in ipairs(t.cargo_wagons) do
      out("  wagon %.1f,%.1f: %s", w.position.x, w.position.y, contents(w.get_inventory(defines.inventory.cargo_wagon)))
    end
    local sch = t.get_schedule()
    local n = sch.get_record_count()
    out("  schedule: %d records, current %s%s", n, tostring(sch.current), t.group and t.group ~= "" and (", group " .. t.group) or "")
    for i = 1, n do
      local r = sch.get_record({ schedule_index = i })
      local conds = {}
      for _, c in ipairs(r.wait_conditions or {}) do conds[#conds + 1] = wait(c) end
      out("    %s%d. %s%s: %s", i == sch.current and "> " or "", i, r.station or (r.rail and string.format("rail %.1f,%.1f", r.rail.position.x, r.rail.position.y) or "?"),
        r.temporary and " (temporary)" or "", #conds > 0 and table.concat(conds, " and ") or "no wait")
    end
  end
  for _, s in pairs(surface.find_entities_filtered({ type = "train-stop" })) do
    local bound = {}
    for _, t in pairs(s.get_train_stop_trains()) do bound[#bound + 1] = t.id end
    out("stop %q at %.1f,%.1f: train limit %s, trains %s", s.backer_name, s.position.x, s.position.y,
      s.trains_limit < 4e9 and s.trains_limit or "none", #bound > 0 and table.concat(bound, " ") or "none")
  end
  -- Can each train reach each stop, driving the way its locomotives face?
  for _, t in pairs(game.train_manager.get_trains({ surface = surface })) do
    for _, s in pairs(surface.find_entities_filtered({ type = "train-stop" })) do
      local p = game.train_manager.request_train_path({ train = t, goals = { s }, type = "path",
        search_direction = "respect-movement-direction" })
      out("path train %d to %q %.0f,%.0f: %s", t.id, s.backer_name, s.position.x, s.position.y,
        p.found_path and string.format("found, %.0f tiles", p.total_length or 0) or "NONE")
    end
  end
  local force = game.forces.player
  for _, name in ipairs({ "railway", "automated-rail-transportation", "fluid-wagon", "cybersyn-train-network" }) do
    local tech = force.technologies[name]
    out("tech %s: %s", name, tech and tostring(tech.researched) or "no such tech")
  end
  -- What Cybersyn itself knows: its depots, refuelers and stations with their networks, the trains it holds.
  if remote.interfaces.cybersyn then
    local function read(...) return remote.call("cybersyn", "read_global", ...) end
    local function net(comb)
      local s = comb.valid and comb.get_or_create_control_behavior().parameters.first_signal
      return s and s.name or "none"
    end
    out("cybersyn: planner %s, warmup %s s, stations warming up %d",
      tostring(remote.call("cybersyn", "read_setting", "enable_planner")),
      tostring(remote.call("cybersyn", "read_setting", "warmup_time")), table_size(read("warmup_station_ids") or {}))
    local function where(s) return string.format("%q at %s %.1f,%.1f", s.backer_name, s.surface.name, s.position.x, s.position.y) end
    for id, d in pairs(read("depots") or {}) do
      out("cybersyn depot %d %s: network %s, parked train %s", id, where(d.entity_stop), net(d.entity_comb), tostring(d.available_train_id))
    end
    for id, r in pairs(read("refuelers") or {}) do
      out("cybersyn refueler %d %s: network %s", id, where(r.entity_stop), net(r.entity_comb))
    end
    for id, s in pairs(read("stations") or {}) do
      out("cybersyn station %d %s: network %s, provider %s, requester %s, trains %s/%s", id, where(s.entity_stop), net(s.entity_comb1),
        tostring(s.is_p), tostring(s.is_r), tostring(s.deliveries_total), tostring(s.trains_limit))
    end
    station_signals()
    -- What the machines around each station are doing (its 240 cell and half a cell round it).
    local seen = {}
    for _, s in pairs(read("stations") or {}) do
      local p = s.entity_stop.position
      local cx, cy = math.floor(p.x / 240) * 240, math.floor(p.y / 240) * 240
      local key = cx .. "," .. cy
      if not seen[key] and s.entity_stop.surface == surface then
        seen[key] = true
        local count = {}
        for _, e in pairs(surface.find_entities_filtered({ area = { { cx - 120, cy - 120 }, { cx + 360, cy + 360 } },
          type = { "assembling-machine", "furnace", "mining-drill" } })) do
          local recipe = e.type ~= "mining-drill" and e.get_recipe()
          local k = string.format("%s%s: %s", e.name, recipe and (" " .. recipe.name) or "", STATUS[e.status] or tostring(e.status))
          count[k] = (count[k] or 0) + 1
        end
        local parts = {}
        for k, v in pairs(count) do parts[#parts + 1] = string.format("%d %s", v, k) end
        table.sort(parts)
        out("machines around cell %s: %s", key, #parts > 0 and table.concat(parts, "; "):sub(1, 1500) or "none")
      end
    end
    for id, t in pairs(read("trains") or {}) do
      out("cybersyn train %d: status %s, available %s, network %s, depot %s", id, tostring(t.status), tostring(t.is_available),
        tostring(t.network_name), tostring(t.depot_id))
    end
    local avail = {}
    for network, set in pairs(read("available_trains") or {}) do avail[#avail + 1] = network .. ": " .. table_size(set) end
    out("cybersyn available trains: %s", #avail > 0 and table.concat(avail, ", ") or "none")
  end
  local ghosts = {}
  for _, g in pairs(surface.find_entities_filtered({ name = "entity-ghost" })) do
    if g.ghost_type == "train-stop" or g.ghost_name:find("cybersyn", 1, true) then
      ghosts[#ghosts + 1] = string.format("%s@%.1f,%.1f", g.ghost_name, g.position.x, g.position.y)
    end
  end
  out("ghosts of stops and Cybersyn combinators: %s", #ghosts > 0 and table.concat(ghosts, " "):sub(1, 600) or "none")
  -- Every surface, so that designs built in a sandbox show up too.
  for _, sf in pairs(game.surfaces) do
    local n = sf.count_entities_filtered({})
    if n > 0 then
      local stops = {}
      for _, s in pairs(sf.find_entities_filtered({ type = "train-stop" })) do
        stops[#stops + 1] = string.format("%s@%.0f,%.0f", s.backer_name, s.position.x, s.position.y)
      end
      out("surface %q: %d entities, %d rails, %d inserters, %d storage tanks, %d stops: %s", sf.name, n,
        sf.count_entities_filtered({ type = "straight-rail" }), sf.count_entities_filtered({ type = "inserter" }),
        sf.count_entities_filtered({ type = "storage-tank" }), #stops, table.concat(stops, " "):sub(1, 900))
      -- Which station is which: where the tanks, chests and splitters stand.
      for _, kind in ipairs({ "storage-tank", "container", "splitter", "straight-rail" }) do
        local cells = {}
        for _, e in pairs(sf.find_entities_filtered({ type = kind })) do
          local key = string.format("%d,%d", math.floor(e.position.x / 240) * 240, math.floor(e.position.y / 240) * 240)
          cells[key] = (cells[key] or 0) + 1
        end
        local parts = {}
        for k, v in pairs(cells) do parts[#parts + 1] = k .. " x" .. v end
        table.sort(parts)
        out("surface %q %s by 240 cell: %s", sf.name, kind, table.concat(parts, " "):sub(1, 1400))
      end
    end
  end
  if again and remote.interfaces.cybersyn then
    script.on_nth_tick(again, function()
      script.on_nth_tick(again, nil)
      station_signals()
    end)
  end
end)
