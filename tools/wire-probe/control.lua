-- Reads, one tick after a copy of a save loads (tools/save-probe.ps1), how the entities on the given
-- tiles are switched by circuits: the enable condition and the logistic condition of their control
-- behavior, the entities each of their wires connects to, and the signals on those circuit
-- networks at that tick. Nothing in the base is changed.
-- Variant: "x:y;x:y;..." (tile positions; belts, poles and pipes on a tile are skipped).

local variant = require("variant")

local function out(fmt, ...) log("CF-WIRE " .. string.format(fmt, ...)) end

local function signal(s)
  if not s then return "-" end
  return (s.type and s.type ~= "item" and (s.type .. "/") or "") .. (s.name or "?")
end

local function condition(c)
  if not c then return "none" end
  local right = c.second_signal and signal(c.second_signal) or tostring(c.constant)
  return string.format("%s %s %s", signal(c.first_signal), c.comparator or "?", right)
end

script.on_event(defines.events.on_tick, function()
  script.on_event(defines.events.on_tick, nil)
  local surface = game.surfaces.nauvis
  for x, y in variant:gmatch("([%-%.%d]+):([%-%.%d]+)") do
    local pos = { tonumber(x), tonumber(y) }
    local e = surface.find_entities_filtered({ position = pos, type = { "transport-belt",
      "underground-belt", "splitter", "electric-pole", "pipe", "pipe-to-ground", "resource" }, invert = true })[1]
    if not e then
      out("%s,%s: nothing", x, y)
    else
      local cb = e.get_control_behavior()
      local parts = {}
      if cb then
        if cb.circuit_enable_disable ~= nil then
          parts[#parts + 1] = "circuit enable " .. tostring(cb.circuit_enable_disable) .. " when " .. condition(cb.circuit_condition)
        end
        if cb.connect_to_logistic_network then
          parts[#parts + 1] = "logistic when " .. condition(cb.logistic_condition)
        end
        if cb.disabled ~= nil then parts[#parts + 1] = "disabled " .. tostring(cb.disabled) end
      end
      out("%s at %s,%s (%s): %s", e.name, e.position.x, e.position.y, tostring(e.status and
        (function() for k, v in pairs(defines.entity_status) do if v == e.status then return k end end end)()),
        #parts > 0 and table.concat(parts, "; ") or "no control behavior")
      for id, connector in pairs(e.get_wire_connectors(false) or {}) do
        local to = {}
        for _, c in pairs(connector.connections) do
          local o = c.target.owner
          to[#to + 1] = string.format("%s@%s,%s", o.name, o.position.x, o.position.y)
        end
        local net = connector.network_id and e.get_circuit_network(id)
        local sig = {}
        if net and net.signals then
          for _, s in pairs(net.signals) do sig[#sig + 1] = signal(s.signal) .. "=" .. s.count end
        end
        out("  wire %s to %s; signals: %s", tostring(id), #to > 0 and table.concat(to, ", ") or "nothing",
          #sig > 0 and table.concat(sig, ", ") or "none")
      end
    end
  end
end)
