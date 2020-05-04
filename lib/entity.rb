module RayCaster
  class Entity
    attr_reader :position,
                :path

    def initialize(position,path)
      @postion  = position
      @path     = path
    end
  end
end
