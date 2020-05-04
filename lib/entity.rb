module RayCaster
  class Entity
    attr_reader :position,
                :texture

    def initialize(position,params)
      @position = position

      @texture  = params[:texture] if params.has_key? :texture
      # get and process other params here...
    end

    def serialize
      { position: @position, texture: @texture }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end
