module Game
  module Data
    TEXTURE_SIZE  = 1 << 5
    
    TEXTURE_FILE  = 'textures/textures.png'
    
    TEXTURES  = { basic_wall:   { width:  TEXTURE_SIZE,
                                  height: TEXTURE_SIZE,
                                  frames: [ [ 0, 0 ] ] },
                  plant_wall:   { width:  TEXTURE_SIZE,
                                  height: TEXTURE_SIZE,
                                  frames: [ [ 6, 0 ] ] },
                  leaking_wall: { width:  TEXTURE_SIZE,
                                  height: TEXTURE_SIZE,
                                  frames: [ [ 3, 0 ], [ 4, 0 ], [ 5, 0 ] ],
                                  mode:   :loop,
                                  speed:  12 },
                  rocks:        { width:  TEXTURE_SIZE,
                                  height: TEXTURE_SIZE,
                                  frames: [ [ 7, 0 ] ] },
                  door:         { width:  TEXTURE_SIZE,
                                  height: TEXTURE_SIZE,
                                  frames: [ [ 1, 0 ] ] },
                  stone:        { width:  TEXTURE_SIZE >> 2,
                                  height: TEXTURE_SIZE,
                                  frames: [ [ 34, 0 ] ] },
                  skull:        { width:  TEXTURE_SIZE >> 2,
                                  height: TEXTURE_SIZE,
                                  frames: [ [ 35, 0 ] ] },
                  spider_web:   { width:  TEXTURE_SIZE >> 1,
                                  height: TEXTURE_SIZE,
                                  frames: [ [ 16, 0 ] ] },
                  brazier:      { width:  TEXTURE_SIZE >> 1,
                                  height: TEXTURE_SIZE,
                                  frames: [ [ 18, 0 ], [ 19, 0 ], [ 20, 0 ] ],
                                  mode:   :pingpong,
                                  speed:  12 } }
  end
end
