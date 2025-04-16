module RayCaster
  class Entity
    attr_reader :type,
                :cell_position,
                :world_position,
                :view_position,
                :texture

    def initialize(map,type,position,entity_types,texture_types,texture_file)
      @type = type

      @cell_position  = [ position[0], position[1] ]
      @world_position = [ map.texture_size * @cell_position[0] + map.texture_size / 2,
                          map.texture_size * @cell_position[1] + map.texture_size / 2 ]


      entity_data   = entity_types[@type]

      texture_data  = texture_types[entity_data[:texture]]
      @texture      = RayCaster::Texture.new(texture_file,
                                             texture_data[:width],
                                             texture_data[:height],
                                             texture_data[:frames],
                                             texture_data[:mode],
                                             texture_data[:speed])

      #entity_data[:params].each_pair do |param,value|
      #  case param
      #  when :param1
      #    # do something with param1
      #  # etc...
      #  end
      #end

      @colide_radius  = entity_data[:colide_radius]
    end

    def compute_view_position(player)
      dx  = @world_position[0] - player.position[0]
      dy  = @world_position[1] - player.position[1]
      @view_position  = [ dy * player.direction[0] - dx * player.direction[1],
                          dx * player.direction[0] + dy * player.direction[1] ]
    end

    def colide?()
      @colide_radius > 0.0
    end

    def update(args,map,player)
      @texture.update if @texture.is_animated
    end

    def serialize
      { position: @world_position, texture: @texture }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end
