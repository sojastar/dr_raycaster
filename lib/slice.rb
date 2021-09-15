module RayCaster
  class Slice
    attr_sprite

    def initialize(x,y,w,h,path,r,g,b,tile_x,tile_y,tile_w,tile_h)
      @x      = x
      @y      = y
      @w      = w
      @h      = h
      @path   = path
      @r      = r
      @g      = g
      @b      = b
      @tile_x = tile_x
      @tile_y = tile_y
      @tile_w = tile_w
      @tile_h = tile_h
    end
  end
end
