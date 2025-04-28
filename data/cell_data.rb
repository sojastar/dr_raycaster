module Game
  module Data
    CELLS = { empty:        { texture: nil,            type: :empty },
              basic_wall:   { texture: :basic_wall,    type: :wall  },
              plant_wall:   { texture: :plant_wall,    type: :wall  },
              leaking_wall: { texture: :leaking_wall,  type: :wall  },
              rocks:        { texture: :rocks,         type: :wall  },
              door:         { texture: :door,          type: :door  } }
  end
end
