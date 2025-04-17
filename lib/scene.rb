module RayCaster
  class Scene
    attr_reader :map, :entities


    # ---=== INITIALIZATION : ===---
    def initialize(map,entities,entity_types,texture_types,texture_file)
      @map  = map

      @entity_types   = entity_types
      @texture_types  = texture_types
      @texture_file   = texture_file

      @entities = []
      entities.each do |entity|
        add_entity_at entity[:type], entity[:position]
      end
    end


    # ---=== ENTITY MANAGEMENT : ===---
    def add_entity_at(entity_type,position)
      new_entity  = RayCaster::Entity.new   @map,
                                            entity_type,
                                            position,
                                            @entity_types,
                                            @texture_types,
                                            @texture_file

      @entities << new_entity
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
