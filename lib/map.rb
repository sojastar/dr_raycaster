module RayCaster
  class Map
    HORIZONTAL  = :horizontal
    VERTICAL    = :vertical

    attr_reader   :width, :height,
                  :texture_size,
                  :pixel_width, :pixel_height,
                  :start_x, :start_y


    # --- INITIALIZATION : ---
    def initialize(map,blocks,textures,start_x,start_y)
      # Map :
      @blocks       = blocks
      @cells        = map.map do |line|
                        line.map do |block|
                          new_cell = @blocks[block].clone
                          if new_cell[:is_door] then
                            new_cell[:is_open]      = false
                            new_cell[:door_offset]  = 0
                          end
                          new_cell
                        end
                      end

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
    def to_cell_coords(x,y)
      [ x.floor.to_i.div(@texture_size),
        y.floor.to_i.div(@texture_size) ]
    end

    def cell_coord(c) c.floor.to_i.div(@texture_size) end
    def cell_x(position)  position[0].floor.to_i.div(@texture_size) end
    def cell_y(position)  position[1].floor.to_i.div(@texture_size) end


    # --- ACCESSORS : ---
    def [](x,y)     @cells[y][x]            end
    def []=(x,y,v)  @cells[y][x] = v.clone  end

    def cell_at(x,y)
      cell_x      = x.floor.to_i / @texture_size
      cell_y      = y.floor.to_i / @texture_size

      @cells[cell_y][cell_x]
    end

    def is_empty_at?(x,y)
      cell_at(x,y)[:texture].nil?
    end

    def has_wall_at?(x,y)
      !cell_at(x,y)[:texture].nil?
    end

    def texture_at(x,y)
      cell_at(x,y)[:texture].nil? ? nil : cell_at(x,y)[:texture].path
    end

    def has_door_at?(x,y)
      cell_at(x,y)[:is_door]
    end

    def door_is_vertical_at(x,y)
      cell_at(x,y)[:orientation] == VERTICAL
    end

    def door_is_horizontal(x,y)
      cell_at(x,y)[:orientation] == HORIZONTAL
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
