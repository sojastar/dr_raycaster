module RayCaster
  class Level
    attr_accessor :blocks, :map
    attr_reader   :width, :height,
                  :pixel_width, :pixel_height,
                  :start_x, :start_y

    def initialize(map,blocks,start_x,start_y)
      # Map :
      @blocks       = blocks
      @map          = map.map { |line| line.map { |tile| @blocks[tile].clone } }
      
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
