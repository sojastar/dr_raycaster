module RayCaster
  class Cell
    attr_reader :texture, :type

    def initialize(texture,type)
      @texture  = texture
      @type     = type
    end
  end

  class Door < Cell
    attr_reader :status, :door_offset

    def initialize(texture)
      super texture, :door
      @status       = :closed
      @door_offset  = texture.width
    end
  end
end
