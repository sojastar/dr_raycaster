module RayCaster
  class Scene
    attr_reader :map, :entities


    # ---=== INITIALIZATION : ===---
    def initialize(map, models, placements)
      @map      = map

      @models   = models

      @entities = placements.map do |placement|
                    RayCaster::Entity.new map, placement[:position], @models[placement[:model]] 
                  end
    end


    # ---=== ENTITY MANAGEMENT : ===---
    def add_entity(model,position)
      @entities << RayCaster::Entity.new( @models[model], position )
    end


    # ---=== UPDATE : ===---
    def update(args,player)
      @map.update args
      #@entities.each { |entity| entity.update args, @map, player }
    end


    # ---=== SERIALIZATION : ===---
    def serialize
      { map: @map.to_s, models: @models, entities: @entities.length }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end
