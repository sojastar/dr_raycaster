module LDtk
  # data["defs"]["tilesets"][0]["customData"]
  # data["levels"][0]["layerInstances"][2]["gridTiles"]
  # data["levels"][0]["layerInstances"][0]["entityInstances"]
  def self.parse(data,texture_size)
    # There is only one tileset so :
    tileset = data['defs']['tilesets'].first

    data['levels'].map do |level|
      cells_layer = level['layerInstances'].select { |layer|
                      layer['__identifier'] == 'cells'
                    }
                    .first

      entities_layer  = level['layerInstances'].select { |layer|
                          layer['__identifier'] == 'entities'
                        }
                        .first

      top_color     = [ 128, 128, 128 ]
      bottom_color  = [ 128, 128, 128 ]
      level['fieldInstances'].each do |field|
        if field['__identifier'] == 'top_color'
          top_color = LDtk.hex_color_to_array_color field['__value']
        end

        if field['__identifier'] == 'bottom_color'
          bottom_color  = LDtk.hex_color_to_array_color field['__value']
        end
      end

      { cells:        LDtk.tile_layer_to_cell_types_array(cells_layer,
                                                          tileset,
                                                          texture_size),
        width:        cells_layer['__cWid'],
        height:       cells_layer['__cHei'],
        entities:     LDtk.entity_layer_to_entity_positions(entities_layer),
        start:        LDtk.level_start(level),
        top_color:    top_color,
        bottom_color: bottom_color }
    end
  end

  def self.tile_layer_to_cell_types_array(layer,tileset,texture_size)
    width   = layer['__cWid']
    height  = layer['__cHei']

    cell_types_array  = Array.new(height) { Array.new(width) { :empty } }

    ids = LDtk.tileset_customData_to_id_hash(tileset)

    layer['gridTiles'].each do |tile|
      tile_x    = width - tile['px'][0] / texture_size
      tile_y    = tile['px'][1] / texture_size
      tile_type = ids[tile['t']]

      cell_types_array[tile_y][tile_x] = tile_type
    end

    cell_types_array
  end

  def self.tileset_customData_to_id_hash(tileset)
    tileset['customData'].map { |data|
      [ data['tileId'], data['data'][1..-2].to_sym ]
    }
    .to_h
  end

  def self.tile_to_map_tile(tile,ids,texture_size)
    { coords: [ tile['px'][0] / texture_size,
                tile['px'][1] / texture_size ],
      type:   ids[tile['t']] }
  end

  def self.entity_layer_to_entity_positions(layer)
    layer['entityInstances'].map { |entity|
      if entity['__identifier'] != 'start'
        { type:     entity['__identifier'].to_sym,
          position: [ layer['__cWid'] - entity['__grid'][0],
                                        entity['__grid'][1] ] }

      else
        nil
      end
    }
    .compact
  end

  def self.level_start(level)
    start_entity  = level['layerInstances'][0]['entityInstances']
                    .select { |entity| entity['__identifier'] == 'start' }
                    .first

    angle =  start_entity['fieldInstances']
             .select { |instance| instance['__identifier'] == 'angle' }
             .first
             .fetch('__value')
             .to_f
    puts angle

    { x:      start_entity['__grid'][0],
      y:      start_entity['__grid'][1],
      angle:  angle }
  end

  def self.hex_color_to_array_color(color)
    color[1..-1].each_char.each_slice(2).map { |c| c[0].to_i(16) * 16 + c[1].to_i(16) }
  end
end
