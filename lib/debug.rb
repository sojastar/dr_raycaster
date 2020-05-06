module Debug
  # ---=== DEBUG MODE PARSING: ===---
  def self.parse_debug_arg(argv)
    argv.split[1..-2].each do |arg|
      debug_flag, level  = arg.split('=')
      return level.to_i if debug_flag == '--debug' && level != nil
    end

    nil
  end


  # ---=== BASIC ELEMENTS : ===---
  def self.draw_cross(position,size,color)
    $gtk.args.outputs.lines <<  [ [ position[0] - size,     position[1] - size,
                                    position[0] + size + 2, position[1] + size + 2 ] + color,
                                  [ position[0] - size,     position[1] + size + 2,
                                    position[0] + size + 2, position[1] - size     ] + color  ]
  end


  # ---=== WORLD SPACE TOP DOWN RENDER : ===---
  def self.render_map_top_down(map,offset)
    blocks  = []
    map.height.times do |y|
      map.width.times do |x|
        #blocks << [ offset[0] + x * 32, offset[1] + y * 32, 32, 32 ] +  case map[x,y][:type]
        #                                                                when 0  then [  0,   0,   0, 255]
        #                                                                when 1  then [255,   0,   0, 255]
        #                                                                when 2  then [  0, 255,   0, 255]
        #                                                                when 3  then [  0,   0, 255, 255]
        #                                                                end
        blocks << [ offset[0] + x * 32, offset[1] + y * 32, 32, 32 ] + ( map[x,y][:texture].nil? ? [255, 255, 255, 255] : [0, 0, 0, 255] )
      end
    end
  
    $gtk.args.outputs.solids << blocks
  end
  
  def self.render_player_top_down(player,renderer,offset)
    # Player's position :
    x = player.position[0] + offset[0]
    y = player.position[1] + offset[1]
    draw_cross(player.position.add(offset), 5, [0, 0, 255, 255])
  
    # Player's direction :
    dx  = renderer.focal * player.direction[0]
    dy  = renderer.focal * player.direction[1]
    $gtk.args.outputs.lines << [x, y, x + dx, y + dy, 0, 0, 255, 255]
  
    # Frustum :
    frustum_left_bound  = renderer.left_frustum_bound   player
    frustum_right_bound = renderer.right_frustum_bound  player
    $gtk.args.outputs.lines <<  player.position.add(offset)    +
                                frustum_left_bound.add(offset) +
                                [255, 0, 0, 255]
    $gtk.args.outputs.lines <<  player.position.add(offset)     +
                                frustum_right_bound.add(offset) +
                                [0, 255, 0, 255]
  end
  
  def self.render_wall_hits(hits,offset)
    hits.each { |hit| draw_cross(hit[:intersection].add(offset), 2, [255, 0 ,255, 255]) }
  end
  
  def self.render_entities(scene,player,offset)
    scene.entities.each do |entity|
      draw_cross entity.world_position.add(offset), 2, [0, 0, 255, 255]
      half_width  = entity.texture.half_width
      $gtk.args.outputs.lines <<  entity.world_position.add(offset).sub( player.direction_normal.mul(half_width) ) +
                                  entity.world_position.add(offset).add( player.direction_normal.mul(half_width) ) +
                                  [0, 0, 255, 255]
    end
  end


  # ---=== VIEW SPACE TOP DOWN RENDER : ===---
  def self.render_view_space(offset)
    $gtk.args.outputs.lines << [ offset[0] - 100, offset[1],       offset[0] + 500, offset[1],       170, 170, 170, 255 ]
    $gtk.args.outputs.lines << [ offset[0],       offset[1] - 100, offset[0],       offset[1] + 500, 140, 140, 140, 255 ]
  end

  def self.render_entities_in_view_space(scene,offset)
    scene.entities.each do |entity|
      draw_cross entity.view_position.add(offset), 10, [0, 0, 255, 255]
    end
  end
end 
