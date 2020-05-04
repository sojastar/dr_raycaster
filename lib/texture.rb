module RayCaster
  class Texture
    attr_reader :path, :width, :offset

    # --- INITIALIZATION : ---
    def initialize(path,width)
      @path   = path
      @width  = width
      @offset = 0
    end

    # --- ANIMATION : ---

    # --- SERIALIZATION : ---
    def serialize
      { path: @path, width: @width, offset: @offset }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end

