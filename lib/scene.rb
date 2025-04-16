module RayCaster
  class Scene
    attr_reader :map, :entities


    # ---=== INITIALIZATION : ===---
    def initialize(map,entities,entity_types,texture_types,texture_file)
      @map  = map

      @entity_types   = entity_types
      @texture_types  = texture_types
      @texture_file   = texture_file

      @entities = entities.map do |entity|
                    RayCaster::Entity.new   map,
                                            entity[:type],
                                            entity[:position],
                                            entity_types,
                                            texture_types,
                                            texture_file
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
      { map: @map.to_s, entities: @entities.length }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end
