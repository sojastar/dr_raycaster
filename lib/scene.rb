module RayCaster
  class Scene
    attr_reader :map, :entities

    def initialize(map, entities)
      @map      = map

      @entities = {}
      entities.each do { |entity| add_entity entity }
    end

    def add_entity(entity,identifier=nil)
      new_entity_identifier = identifier.nil? ? "entity#{@entities.length}" : identifier
      @entities[new_entity_identifier] = RayCaster::Entity.new **entity
    end
  end
end
