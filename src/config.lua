-- Example config file
{
  debug = {
    drawBoundingBoxes = false
  },
  meters = {
    {
      -- The name of the meter
      name = "clock",
      -- The X position of the meter
      x = 4,
      -- The Y position of the meter
      y = 4,
      -- The size of the text
      textSize = 1.25
      -- Timezone offset from UTC
      tzoffset = 0
    },
    {
      name = "date",
      x = 4,
      -- after:<id> can be used to place the meter after another meter. This only works for Y values.
      y = "after:clock",
      textSize = 0.5
      tzoffset = 0
    },
    {
      name = "claim",
      x = 4,
      y = "after:date",
      textSize = 0.5
    },
    {
      -- For meters of which you have multiple, you can specify an ID. This is used to identify the meter in the code.
      id = "kznepbmewt",
      name = "krist",
      kristName = "kznepbmewt",
      x = 4,
      y = "after:claim",
      textSize = 0.4
    },
    {
      id = "ksnowflake",
      name = "krist",
      kristName = "ksnowflake",
      x = 4,
      y = "after:kznepbmewt",
      textSize = 0.4
    },
    {
      id = "kqxhx5yn9v",
      name = "krist",
      kristName = "kqxhx5yn9v",
      x = 4,
      y = "after:ksnowflake",
      -- disableTruncate will disable the "K" and "M" suffixes for large numbers
      disableTruncate = true,
      textSize = 0.4
    }
  }
}