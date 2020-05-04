module RayCaster
  class Entity
    attr_reader :position,
                :path

    def initialize(position,path)
      @position = position
      @path     = path
    end
  end
end
