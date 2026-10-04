-- Small helpers shared by the agent's observe and act modules.
local util = {}

util.dirs = { N = defines.direction.north, E = defines.direction.east, S = defines.direction.south, W = defines.direction.west }
util.dir_names = {}
for k, v in pairs(util.dirs) do util.dir_names[v] = k end

util.status_names = {}
for k, v in pairs(defines.entity_status) do util.status_names[v] = k end

function util.round(x, step)
  step = step or 0.5
  return math.floor(x / step + 0.5) * step
end

function util.pos(p)
  return { x = util.round(p.x or p[1]), y = util.round(p.y or p[2]) }
end

function util.dist(a, b)
  local dx, dy = (a.x or a[1]) - (b.x or b[1]), (a.y or a[2]) - (b.y or b[2])
  return math.sqrt(dx * dx + dy * dy)
end

function util.fmt_time(tick)
  local s = math.floor(tick / 60)
  return string.format("%d:%02d:%02d", math.floor(s / 3600), math.floor(s / 60) % 60, s % 60)
end

-- {name = count} of an inventory, all qualities together.
function util.contents(inv)
  local out = {}
  if not (inv and inv.valid) then return out end
  for _, c in pairs(inv.get_contents()) do out[c.name] = (out[c.name] or 0) + c.count end
  return out
end

function util.is_empty(t) return next(t) == nil end

-- Accepts {x=, y=} or {x, y} or args with x/y keys.
function util.xy(a)
  if a.x and a.y then return { x = a.x, y = a.y } end
  if a.pos then return { x = a.pos[1] or a.pos.x, y = a.pos[2] or a.pos.y } end
  return nil
end

function util.area_around(p, r)
  return { { p.x - r, p.y - r }, { p.x + r, p.y + r } }
end

-- The entity of the player's force at a position, preferring one with the given name.
function util.entity_at(surface, p, name)
  local list = surface.find_entities_filtered { position = p, force = "player", name = name }
  if #list == 0 then
    list = surface.find_entities_filtered { area = { { p.x - 0.5, p.y - 0.5 }, { p.x + 0.5, p.y + 0.5 } }, force = "player", name = name }
  end
  for _, e in pairs(list) do
    if e.type ~= "character" then return e end
  end
  return nil
end

function util.inventories(e)
  -- Every inventory an entity has, keyed by define name.
  local out = {}
  for i = 1, e.get_max_inventory_index() do
    local inv = e.get_inventory(i)
    if inv and inv.valid and #inv > 0 then out[inv.name or tostring(i)] = inv end
  end
  return out
end

-- Item that places an entity (first one), or nil.
function util.place_item(name)
  local proto = prototypes.entity[name]
  if not proto then return nil end
  local items = proto.items_to_place_this
  return items and items[1] and (items[1].name or items[1]) or nil
end

return util
