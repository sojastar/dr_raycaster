module RayCaster
  class Level
    attr_accessor :blocks, :map
    attr_reader   :width, :height,
                  :texture_size,
                  :pixel_width, :pixel_height,
                  :start_x, :start_y

    def initialize(map,blocks,start_x,start_y)
      # Map :
      @blocks       = blocks
      @map          = map.map { |line| line.map { |tile| @blocks[tile].clone } }

      @texture_size = blocks[:te][:size]
      
      @width        = @map.first.length
      @height       = @map.length
      @pixel_width  = @width  * @blocks[:te][:size]
      @pixel_height = @height * @blocks[:te][:size]

      # Spawn position :
      @start_x  = start_x
      @start_y  = start_y
    end

    def set_block(x,y,identifier)
      @map[y][x] = @blocks[:identifier].clone
    end

    def [](x,y)     @map[y][x]        end
    def []=(x,y,v)  @map[y][x] = v    end

    def tile_coord(c) c.floor.to_i / @texture_size end
    alias tile_x tile_coord
    alias tile_y tile_coord

    def to_tile_coords(x,y)
      [ x.floor.to_i / @texture_size,
        y.floor.to_i / @texture_size ]
    end

    def tile_at(x,y)
      tile_x      = x.floor.to_i / @texture_size
      tile_y      = y.floor.to_i / @texture_size

      @map[tile_y][tile_x]
    end

    def is_empty_at?(x,y)
      tile_at(x,y)[:texture].nil?
    end
    
    def has_wall_at?(x,y)
      !tile_at(x,y)[:texture].nil?
    end

    def texture_at(x,y)
      tile_at(x,y)[:texture]
    end

    def serialize
      { map:      @map,
        start_x:  @start_x,
        start_y:  @start_y,
        blocks:   @blocks }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end
