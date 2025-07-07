module Debug
  class DebugOverlay
    RED         = [ 255,   0,   0, 255 ]
    GREEN       = [   0, 255,   0, 255 ]
    BLUE        = [   0,   0, 255, 255 ]
    YELLOW      = [ 255, 255,   0, 255 ]
    ORANGE      = [ 255, 127,   0, 255 ]
    LIGHT_BLUE  = [ 127, 127, 255, 255 ]
    CYAN        = [   0, 255, 255, 255 ]
    PURPLE      = [ 128,   0, 255, 255 ]
    MAGENTA     = [ 255,   0, 255, 255 ]

    attr_sprite
    attr_accessor :should_draw

    # ---=== INITIALIZATION : ===---
    def initialize
      @offset       =  [ 0, 0 ]
      @should_draw  = false
    end

    # ---=== BASIC ELEMENTS : ===---
    def draw_cross(x,y,size,color)
      $gtk.args.render_target(:debug).lines << [[x - size,
                                                 y - size,
                                                 x + size + 2,
                                                 y + size + 2] + color,
                                                [x - size,
                                                 y + size + 2,
                                                 x + size + 2,
                                                 y - size] + color]
    end

    # ---=== WORLD SPACE TOP DOWN RENDER : ===---
    def render_game_top_down(game)
      render_map_top_down     game.scene.map
      render_player_top_down  game.player, game.renderer
      render_wall_hits        game.renderer.columns
      render_entities         game.scene, game.player
    end

    def render_map_top_down(map)
      cells = []
      map.height.times do |y|
        map.width.times do |x|
          texture = map[x, y].texture
          next if texture.nil?

          cells << { x: @offset[0] + Game::Data::TEXTURE_SIZE * x,
                     y: @offset[1] + Game::Data::TEXTURE_SIZE * y,
                     w: Game::Data::TEXTURE_SIZE,
                     h: Game::Data::TEXTURE_SIZE,
                     path: texture.path,
                     source_x: texture.source_x,
                     source_y: texture.source_y,
                     source_w: Game::Data::TEXTURE_SIZE,
                     source_h: Game::Data::TEXTURE_SIZE }
        end
      end

      $gtk.args.render_target(:debug).sprites << cells
    end

    def render_player_top_down(player,renderer)
      # Player's position :
      x   = $gtk.args.grid.right / 2
      y   = $gtk.args.grid.top / 2
      draw_cross x, y, 10, RED

      # Player's direction :
      dx  = renderer.focal * player.direction[0]
      dy  = renderer.focal * player.direction[1]
      $gtk.args.render_target(:debug).lines << ( [ x, y, x + dx, y + dy ] + ORANGE )

      # Frustum :
      frustum_left_bound  = renderer.left_frustum_bound   player
      frustum_right_bound = renderer.right_frustum_bound  player
      $gtk.args.render_target(:debug).lines <<  player.position.add(@offset)    +
                                                frustum_left_bound.add(@offset) +
                                                CYAN
      $gtk.args.render_target(:debug).lines <<  player.position.add(@offset)     +
                                                frustum_right_bound.add(@offset) +
                                                MAGENTA

      # Look at tile :
      look_at = player.position.add(player.direction.mul(24))
      draw_cross  look_at[0] + @offset[0],
                  look_at[1] + @offset[1],
                  5,
                  YELLOW
    end

    def render_wall_hits(columns)
      columns.each do |column|
        color = RED
        # color = case column.first[:from]
        #        when :horizontal_ray_casting_method                   then [ 255, 0, 0, 255 ]
        #        when :horizontal_ray_casting_through_door_DOOR_method then [ 0, 255, 0, 255 ]
        #        when :horizontal_ray_casting_through_door_WALL_method then [ 0, 0, 255, 255 ]
        #        when :vertical_ray_casting_method                     then [ 255, 0, 0, 255 ]
        #        when :vertical_ray_casting_through_door_DOOR_method   then [ 0, 255, 0, 255 ]
        #        when :vertical_ray_casting_through_door_WALL_method   then [ 0, 0, 255, 255 ]
        #        end
        #draw_cross(column.first[:intersection].add(offset), 1, color)
        draw_cross  column.first[:intersection][0] + @offset[0],
                    column.first[:intersection][1] + @offset[1],
                    1,
                    color
      end
    end

    def render_entities(scene,player)
      scene.entities.each do |entity|
        draw_cross  entity.world_position[0] + @offset[0],
                    entity.world_position[1] + @offset[1],
                    2,
                    BLUE

        half_width = entity.texture.half_width
        $gtk.args.outputs.lines <<  entity.world_position.add(@offset).sub(player.direction_normal.mul(half_width)) +
          entity.world_position.add(@offset).add(player.direction_normal.mul(half_width)) +
          LIGHT_BLUE
      end
    end

    def render(game)
      if @should_draw
        @offset[0]  = $gtk.args.grid.right / 2 - game.player.position[0]
        @offset[1]  = $gtk.args.grid.top / 2 - game.player.position[1]

        $gtk.args.render_target(:debug).width   = $gtk.args.grid.right
        $gtk.args.render_target(:debug).height  = $gtk.args.grid.top

        render_game_top_down(game)

        @x    = 0
        @y    = 0
        @w    = $gtk.args.grid.right
        @h    = $gtk.args.grid.top
        @path = :debug

      else
        @x, @y, @w, @h = -1, -1, 0, 0

      end
    end
  end
end
