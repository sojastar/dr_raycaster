module RayCaster
  class Slice
    attr_sprite

    def initialize(x,y,w,h,path,r,g,b,source_x,source_y,source_w,source_h)
      @x        = x
      @y        = y
      @w        = w
      @h        = h
      @path     = path
      @r        = r
      @g        = g
      @b        = b
      @source_x = source_x
      @source_y = source_y
      @source_w = source_w
      @source_h = source_h

      @needs_drawing = false
    end

    def should_draw
      @needs_drawing = true
    end

    def should_not_draw
      @needs_drawing = false
    end

    def draw_override(ffi_draw)
      if @needs_drawing
        ffi_draw.draw_sprite_3 @x, @y, @w, @h,
                              @path,
                              0.0,
                              255, @r, @g, @b,
                              nil, nil, nil, nil, # tile_x|y|w|h
                              false, false,       # flip_horizontally|vertically
                              0.0, 0.0,           # anchor_x|y
                              @source_x, @source_y, @source_w, @source_h
      end
    end

    def serialize
      { x: @x, y: @y, w: @w, h: @h, path: @path, source_x: @source_x, source_y: @source_y, source_w: @source_w, source_h: @source_h, needs_drawing: @needs_drawing }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end
