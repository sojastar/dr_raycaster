module RayCaster
  class Map
    #attr_accessor :blocks, :map
    attr_reader   :width, :height,
                  :texture_size,
                  :pixel_width, :pixel_height,
                  :start_x, :start_y


    # --- INITIALIZATION : ---
    def initialize(map,blocks,textures,start_x,start_y)
      # Map :
      @blocks       = blocks
      @cells        = map.map { |line| line.map { |tile| @blocks[tile].clone } }

      @texture_size = blocks[:t1][:texture].width
      
      @width        = @cells.first.length
      @height       = @cells.length
      @pixel_width  = @width  * @blocks[:t1][:texture].width
      @pixel_height = @height * @blocks[:t1][:texture].width

      # Spawn position :
      @start_x      = start_x
      @start_y      = start_y
    end

    def set_block_at(x,y,identifier)
      @cells[y][x]  = @blocks[identifier].clone
    end


    # --- PIXEL AND TILE COORDINATES CONVERSIONS : ---
    def to_tile_coords(x,y)
      [ x.floor.to_i / @texture_size,
        y.floor.to_i / @texture_size ]
    end

    def tile_coord(c) c.floor.to_i / @texture_size end
    alias tile_x tile_coord
    alias tile_y tile_coord


    # --- ACCESSORS : ---
    def [](x,y)     @cells[y][x]            end
    def []=(x,y,v)  @cells[y][x] = v.clone  end

    def tile_at(x,y)
      tile_x      = x.floor.to_i / @texture_size
      tile_y      = y.floor.to_i / @texture_size

      @cells[tile_y][tile_x]
    end

    def is_empty_at?(x,y)
      tile_at(x,y)[:texture].nil?
    end
    
    def has_wall_at?(x,y)
      !tile_at(x,y)[:texture].nil?
    end

    def texture_at(x,y)
      #tile_at(x,y)[:texture].path
      tile_at(x,y)[:texture].nil? ? nil : tile_at(x,y)[:texture].path
    end


    # --- SERIALIZATION : ---
    def serialize
      { cells:    @cells,
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
