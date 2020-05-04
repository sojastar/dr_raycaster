module RayCaster
  class Scene
    attr_reader :map, :entities

    def initialize(map, models, placements)
      @map      = map

      @models   = models
      #entities.each { |entity| add_entity entity }

      @entities = placements.map do |placement|
                    RayCaster::Entity.new placement[:position], @models[placement[:model]] 
                  end
    end

    def add_entity(model,position)
      @entities << RayCaster::Entity.new( @models[model], position )
    end
  end
end
