-- Samples, on every tick from the moment a copy of a save loads (tools/save-probe.ps1), the
-- status and electric buffer of every entity with the given name: tells a state the base is in
-- from one that a single tick shows (the save inspector reads statuses on one tick only).
-- Variant: "name,ticks" (ticks default 600). Prints per entity the status on the first tick, the
-- share of each status, the lowest and mean fill of its electric buffer, the effects of its
-- modules and beacons, and its energy use per tick against the buffer it has; then, over all
-- entities of the name, the statuses on the first tick, in the rest of the first second and after.

local variant = require("variant")
local NAME, TICKS = variant:match("^([%w%-_]+),?(%d*)$")
TICKS = tonumber(TICKS) or 600

local function out(fmt, ...) log("CF-STATUS " .. string.format(fmt, ...)) end
local STATUS = {}
for k, v in pairs(defines.entity_status) do STATUS[v] = k end

local function shares(counts)
  local total, parts = 0, {}
  for _, n in pairs(counts) do total = total + n end
  for st, n in pairs(counts) do parts[#parts + 1] = string.format("%s %.1f%%", st, 100 * n / total) end
  table.sort(parts)
  return table.concat(parts, ", ")
end

local function report(s)
  for _, r in ipairs(s.list) do
    local e = r.e
    if e.valid then
      local fx, parts = e.effects or {}, {}
      for k, v in pairs(fx) do parts[#parts + 1] = string.format("%s %+.0f%%", k, 100 * v) end
      table.sort(parts)
      local src = e.prototype.electric_energy_source_prototype
      local use = e.prototype.get_max_energy_usage() * (1 + (fx.consumption or 0))
      out("%s at %.1f,%.1f: first tick %s; %s; buffer fill lowest %.3f, mean %.3f (size %.0f J); effects %s; use %.0f J/tick with its modules, prototype buffer %s J, input limit %s J/tick",
        e.name, e.position.x, e.position.y, r.first or "-", shares(r.counts), r.low, r.n > 0 and r.sum / r.n or 0,
        e.electric_buffer_size or 0, table.concat(parts, ", "), use,
        src and tostring(src.buffer_capacity) or "-", src and tostring(src.get_input_flow_limit()) or "-")
    end
  end
  out("all %s, first tick: %s", NAME, shares(s.windows.first))
  out("all %s, rest of the first second: %s", NAME, shares(s.windows.second))
  out("all %s, after the first second: %s", NAME, shares(s.windows.rest))
end

script.on_event(defines.events.on_tick, function()
  local s = storage
  if not s.list then
    s.start, s.list = game.tick, {}
    s.windows = { first = {}, second = {}, rest = {} }
    for _, e in pairs(game.surfaces.nauvis.find_entities_filtered({ name = NAME })) do
      s.list[#s.list + 1] = { e = e, counts = {}, low = math.huge, sum = 0, n = 0 }
    end
    out("loaded at tick %d; %d %s; sampling %d ticks", game.tick, #s.list, NAME, TICKS)
  end
  local t = game.tick - s.start
  if t >= TICKS then
    if not s.done then s.done = true; report(s) end
    return
  end
  local w = t == 0 and s.windows.first or (t < 60 and s.windows.second or s.windows.rest)
  for _, r in ipairs(s.list) do
    local e = r.e
    if e.valid then
      local st = STATUS[e.status] or "?"
      r.first = r.first or st
      r.counts[st] = (r.counts[st] or 0) + 1
      w[st] = (w[st] or 0) + 1
      local size = e.electric_buffer_size
      if size and size > 0 then
        local f = e.energy / size
        if f < r.low then r.low = f end
        r.sum, r.n = r.sum + f, r.n + 1
      end
    end
  end
end)
