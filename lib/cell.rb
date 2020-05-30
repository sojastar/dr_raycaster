module RayCaster
  class Cell
    attr_reader :texture, :type

    def initialize(texture,type)
      @texture  = texture
      @type     = type
    end

    def clone
      Cell.new(@texture, @type)
    end

    def serialize
      { texture: @texture, type: @type }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end

  class Door < Cell
    attr_accessor :status, :door_offset

    def initialize(texture,status=:closed,door_offset=-1)
      super texture, :door
      @status       = status
      @door_offset  = door_offset == -1 ? texture.width : door_offset
    end

    def clone
      Door.new @texture, @status, @door_offset
    end
  end
end
