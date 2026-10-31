-- Reads, one tick after a copy of a save loads (tools/save-probe.ps1), every train and train stop:
-- for a train its cars, state, manual or automatic, schedule (records with their wait
-- conditions, the current one marked), fuel and burnt results of each locomotive and the cargo;
-- for a stop its name, place, train limit and the trains bound for it. Nothing in the base is
-- changed. Variant: unused.

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
      for _, kind in ipairs({ "storage-tank", "container", "splitter" }) do
        local cells = {}
        for _, e in pairs(sf.find_entities_filtered({ type = kind })) do
          local key = string.format("%d,%d", math.floor(e.position.x / 240) * 240, math.floor(e.position.y / 240) * 240)
          cells[key] = (cells[key] or 0) + 1
        end
        local parts = {}
        for k, v in pairs(cells) do parts[#parts + 1] = k .. " x" .. v end
        table.sort(parts)
        out("surface %q %s by 240 cell: %s", sf.name, kind, table.concat(parts, " "):sub(1, 400))
      end
    end
  end
end)
