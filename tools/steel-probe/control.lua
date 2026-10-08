-- Measures the author's steel site inside a copy of their save (tools/save-probe.ps1). On load it
-- empties the steel chest and lifts its limit (the line had stopped on a full chest), takes the
-- Steel off the site's belts and out of the foundries, empties every Boiler's Ash (so power is
-- not the limit) and sets the Soil extractors' circuit condition
-- by variant; then, after a two-minute warm-up, it samples every steel foundry for ten minutes:
-- Steel made, status, and which ingredient is short whenever one waits.
-- Variants: "as-built" (Limestone < 5, the author's), "lt10" (Limestone < 10), "off" (no
-- condition: the extractor always runs).

local variant = require("variant")
local WARM, MEASURE, EVERY = 7200, 36000, 60
local NEED = { ["iron-ore"] = 20, coke = 5, limestone = 5 }

local function out(fmt, ...) log("CF-STEEL " .. string.format(fmt, ...)) end
local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end

script.on_init(function()
  local surface = game.surfaces.nauvis
  local foundries = {}
  for _, e in pairs(surface.find_entities_filtered({ name = "advanced-foundry-mk01" })) do
    local r = e.get_recipe()
    if r and r.name == "steel-plate" then foundries[#foundries + 1] = e end
  end
  table.sort(foundries, function(a, b) return a.position.x < b.position.x end)

  local cleared = 0
  for _, c in pairs(surface.find_entities_filtered({ type = "container" })) do
    local inv = c.get_inventory(defines.inventory.chest)
    if inv and inv.get_item_count("steel-plate") > 0 then
      cleared = cleared + inv.get_item_count("steel-plate")
      inv.clear()
      if inv.supports_bar() then inv.set_bar() end
    end
  end
  -- Steel still on the site's belts from the stop would take minutes to drain through the one
  -- chest inserter and block the foundries meanwhile: remove it too.
  local f1, f8 = foundries[1].position, foundries[#foundries].position
  for _, b in pairs(surface.find_entities_filtered({
    area = { { f1.x - 8, f1.y + 3 }, { f8.x + 4, f1.y + 7 } }, type = { "transport-belt", "underground-belt" } })) do
    for line = 1, b.get_max_transport_line_index() do
      local tl = b.get_transport_line(line)
      local n = tl.get_item_count("steel-plate")
      if n > 0 then cleared = cleared + tl.remove_item({ name = "steel-plate", count = n }) end
    end
  end
  for _, f in ipairs(foundries) do
    local inv = f.get_inventory(defines.inventory.crafter_output)
    cleared = cleared + inv.get_item_count("steel-plate")
    inv.clear()
  end
  local ash = 0
  for _, b in pairs(surface.find_entities_filtered({ type = "boiler" })) do
    local inv = b.get_burnt_result_inventory()
    if inv then ash = ash + inv.get_item_count(); inv.clear() end
  end

  local extractors, condition = {}, nil
  for _, e in pairs(surface.find_entities_filtered({ name = "soil-extractor-mk01" })) do
    local r = e.get_recipe()
    if r and r.name == "extract-limestone-01" then
      extractors[#extractors + 1] = e
      local cb = e.get_control_behavior()
      if cb then
        local c = cb.circuit_condition
        condition = condition or string.format("%s %s %s", c.first_signal and c.first_signal.name or "?", c.comparator, tostring(c.constant))
        if variant == "off" then cb.circuit_enable_disable = false
        elseif variant == "lt10" then c.constant = 10; cb.circuit_condition = c end
      end
    end
  end
  out("variant %s: %d steel foundries, %d Limestone extractors (built with: %s); emptied %d Steel from chests, %d Ash from Boilers",
    variant, #foundries, #extractors, condition or "no circuit", cleared, ash)

  local rows = {}
  for i, f in ipairs(foundries) do rows[i] = { e = f, status = {}, short = {} } end
  storage.probe = { start = game.tick, rows = rows, extractors = extractors, ext_status = {} }
end)

script.on_nth_tick(EVERY, function()
  local p = storage.probe
  if not p then return end
  local t = game.tick - p.start
  if t < WARM then return end
  if not p.finished0 then
    p.finished0 = true
    for _, r in ipairs(p.rows) do r.done0 = r.e.products_finished end
    return
  end
  for _, r in ipairs(p.rows) do
    local s = STATUS[r.e.status] or "?"
    r.status[s] = (r.status[s] or 0) + 1
    if s == "item_ingredient_shortage" then
      local inv = r.e.get_inventory(defines.inventory.crafter_input)
      for item, n in pairs(NEED) do
        if inv.get_item_count(item) < n then r.short[item] = (r.short[item] or 0) + 1 end
      end
    end
  end
  for _, e in ipairs(p.extractors) do
    local s = STATUS[e.status] or "?"
    p.ext_status[s] = (p.ext_status[s] or 0) + 1
  end
  if t >= WARM + MEASURE then
    local total = 0
    local function list(t) local parts = {} for k, v in pairs(t) do parts[#parts + 1] = k .. " " .. v end table.sort(parts) return table.concat(parts, ", ") end
    for i, r in ipairs(p.rows) do
      local made = r.e.products_finished - r.done0
      total = total + made
      out("foundry %d at x %.0f: %d Steel = %.2f/min; status samples: %s; short of: %s",
        i, r.e.position.x, made, made / (MEASURE / 3600), list(r.status), list(r.short))
    end
    out("total %.3f Steel/s over %d s (data: 0.533 for 8 foundries); extractor status samples: %s",
      total / (MEASURE / 60), MEASURE / 60, list(p.ext_status))
    -- Which lane carries what on the belts below the foundries (Coke and Steel share one belt).
    local f1, f8 = p.rows[1].e.position, p.rows[#p.rows].e.position
    local belts = game.surfaces.nauvis.find_entities_filtered({
      area = { { f1.x - 8, f1.y + 3 }, { f8.x + 4, f1.y + 7 } }, type = { "transport-belt", "underground-belt" } })
    table.sort(belts, function(a, b) return a.position.y < b.position.y or (a.position.y == b.position.y and a.position.x < b.position.x) end)
    for _, b in ipairs(belts) do
      local lanes = {}
      for line = 1, 2 do
        local tl = b.get_transport_line(line)
        local c, s = tl.get_item_count("coke"), tl.get_item_count("steel-plate")
        if c + s > 0 then lanes[#lanes + 1] = string.format("lane %d: coke %d steel %d", line, c, s) end
      end
      if #lanes > 0 then
        out("belt %s at (%.1f, %.1f) %s: %s", b.type, b.position.x, b.position.y, b.direction, table.concat(lanes, "; "))
      end
    end
    storage.probe = nil
  end
end)
