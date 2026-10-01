data:extend({
  {
    type = "bool-setting",
    name = "pt-recorder-enabled",
    setting_type = "runtime-global",
    default_value = true,
    order = "a",
  },
  {
    type = "int-setting",
    name = "pt-recorder-segment-mb",
    setting_type = "runtime-global",
    default_value = 4,
    minimum_value = 1,
    maximum_value = 64,
    order = "b",
  },
  {
    type = "int-setting",
    name = "pt-recorder-keep-segments",
    setting_type = "runtime-global",
    default_value = 16,
    minimum_value = 1,
    maximum_value = 1000,
    order = "c",
  },
})
