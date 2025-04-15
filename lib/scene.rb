module RayCaster
  class Scene
    attr_reader :map, :entities


    # ---=== INITIALIZATION : ===---
    def initialize(map,models,entities)
      @map      = map

      @models   = models

      @entities = entities.map do |entity|
                    RayCaster::Entity.new map,
                                          entity[:position],
                                          @models[entity[:model]]
                  end
    end


    # ---=== ENTITY MANAGEMENT : ===---
    def add_entity(model,position)
      @entities << RayCaster::Entity.new( @models[model], position )
    end


    # ---=== UPDATE : ===---
    def update(args,player)
      @map.update args
      @entities.each { |entity| entity.update args, @map, player }
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
