module RayCaster
  class Texture
    attr_reader :path,
                :width, :half_width,
                :offset

    # --- INITIALIZATION : ---
    def initialize(path,width)
      @path       = path
      @width      = width
      @half_width = width >> 1
      @offset     = 0
    end

    # --- ANIMATION : ---

    # --- SERIALIZATION : ---
    def serialize
      { path: @path, width: @width, offset: @offset }
    end

    def clone
      Texture.new @path, @width
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end

