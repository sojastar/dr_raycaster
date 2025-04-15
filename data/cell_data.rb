module Game
  CELLS = { empty:        { texture: nil,            type: :empty },
            basic_wall:   { texture: :basic_wall,    type: :wall  },
            plant_wall:   { texture: :plant_wall,    type: :wall  },
            leaking_wall: { texture: :leaking_wall,  type: :wall  },
            rocks:        { texture: :rocks,         type: :wall  },
            door:         { texture: :door,          type: :door  } }
  #CELLS = { te: RayCaster::Cell.new(nil,                      :empty),
  #          t1: RayCaster::Cell.new(textures[:basic_wall],    :wall),
  #          t2: RayCaster::Cell.new(textures[:plant_wall],    :wall),
  #          t3: RayCaster::Cell.new(textures[:leaking_wall],  :wall),
  #          ro: RayCaster::Cell.new(textures[:rocks],         :wall),
  #          do: RayCaster::Door.new(textures[:door]) }
end
