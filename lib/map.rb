module RayCaster
  class Map
    attr_reader   :width, :height,
                  :texture_size,
                  :pixel_width, :pixel_height


    # ---=== INITIALIZATION : ===---
    def initialize(map,cell_types,texture_size)
      # Map :
      @texture_size   = texture_size
      @cell_types     = cell_types
      @doors          = []
      @animated_cells = []
      @cells          = map.map do |row|
                          row.map do |cell_type|
                            new_cell = @cell_types[cell_type].clone
                            @doors          << new_cell if new_cell.type == :door
                            @animated_cells << new_cell if new_cell.is_animated?
                            new_cell
                          end
                        end

      @width          = @cells.first.length
      @height         = @cells.length
      @pixel_width    = @width  * @texture_size
      @pixel_height   = @height * @texture_size
    end

    def set_block_at(x,y,identifier)
      @cells[y][x]  = @block_types[identifier].clone
    end


    # ---=== PIXEL AND TILE COORDINATES CONVERSIONS : ===---
    def to_cell_coords(x,y)
      [ x.floor.to_i.div(@texture_size),
        y.floor.to_i.div(@texture_size) ]
    end

    def cell_coord(c) c.floor.to_i.div(@texture_size) end
    def cell_x(position)  position[0].floor.to_i.div(@texture_size) end
    def cell_y(position)  position[1].floor.to_i.div(@texture_size) end

    def clip_x(x)
      if    x >= @width then  @width - 1
      elsif x < 0       then  0
      else                    x
      end
    end

    def clip_y(y)
      if    y >= @height  then  @height - 1
      elsif y < 0         then  0
      else                      y
      end
    end


    # ---=== ACCESSORS : ===---
    def [](x,y)     @cells[y][x]            end

    def cell_at(x,y)
      cell_x      = clip_x(x.floor.to_i / @texture_size)
      cell_y      = clip_y(y.floor.to_i / @texture_size)

      @cells[cell_y][cell_x]
    end

    def is_empty_at?(x,y)
      cell_at(x,y).type == :empty
    end

    def has_wall_at?(x,y)
      !cell_at(x,y).texture.nil?
    end

    def texture_at(x,y)
      cell_at(x,y).texture.nil? ? nil : cell_at(x,y).texture
    end

    def has_door_at?(x,y)
      !cell_at(x,y).nil? && cell_at(x,y).type == :door
    end

    def cant_pass_through?(x,y)
      cell = cell_at(x,y)

      if cell.type == :door then
        cell.door_offset > @texture_size >> 2
      else
        !cell_at(x,y).texture.nil?
      end
    end


    # ---=== UPDATE : ===---
    def update(args)
      update_cells_animations
      update_doors
    end

    def update_cells_animations
      @animated_cells.each { |cell| cell.update }
    end

    def update_doors
      @doors.each { |door| door.update() }
    end


    # ---=== SERIALIZATION : ===---
    def serialize
      { cells:    @cells,
        #start_x:  @start_x,
        #start_y:  @start_y,
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
