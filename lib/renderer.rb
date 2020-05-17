module RayCaster
  class Renderer
    EPSILON       =  0.1
    MAX_DISTANCE  = 64000
    NO_HIT        = { distance:       MAX_DISTANCE,
                      intersection:   [0.0, 0.0],
                      texture:        nil,
                      texture_select: 0,
                      texture_offset: 0 }

    attr_reader :viewport_width, :viewport_height, :focal


    # ---=== INITIALIZATION : ===---
    def initialize(viewport_width,viewport_height,focal,near,far,texture_size)
      @viewport_width             = viewport_width
      @viewport_half_width        = viewport_width >> 1 
      @viewport_height            = viewport_height
      #@viewport_half_height       = viewport_height>> 1 

      @focal                      = focal
      @frustum_slope              = @viewport_half_width.to_f / focal 

      @near                       = near
      @far                        = far

      @texture_size               = texture_size
      @viewport_texture_factor    = @viewport_height * @texture_size

      @columns                    = []

      @fisheye_correction_factors = @viewport_width.times.map do |i|
                                      p1 = [ i - viewport_width / 2, @focal ]
                                      p2 = [ 0.0, 0.0 ]

                                      1.5 * @focal / Trigo::magnitude(p1, p2)
                                    end
    end


    # ---=== GLOBAL RENDERING : ===---
    def render(scene,player)
      cast_wall_rays  player, scene.map 
      render_entities player, scene.entities

      @columns
    end


    # ---=== WALL RENDERING : ===---
    def cast_wall_rays(player,map)
      ray_end = right_frustum_bound player

      @viewport_width.times do |ray_index|

        # Setup the ray parameters :
        h_ray = horizontal_ray_casting_setup  map, player, ray_end.sub(player.position)
        v_ray = vertical_ray_casting_setup    map, player, ray_end.sub(player.position)

        # Casting the rays until a wall or a door is hit :
        h_hit = horizontal_ray_casting        map, player, h_ray[:start], h_ray[:delta]
        v_hit = vertical_ray_casting          map, player, v_ray[:start], v_ray[:delta]

        @columns[ray_index] = h_hit[:distance] > v_hit[:distance] ? [ v_hit ] : [ h_hit ]

        unless @columns[ray_index].first[:texture].nil? then
          @columns[ray_index].first[:height]  = @viewport_texture_factor / ( @columns[ray_index].first[:distance] * @fisheye_correction_factors[ray_index] )   # the wall is ALWAYS the FIRST layer of a rendering column
        end

        ray_end = ray_end.sub(player.direction_normal)
      end
    end

    def right_frustum_bound(player)
      [ player.position[0] + @focal * player.direction[0] + @viewport_half_width * player.direction_normal[0],
        player.position[1] + @focal * player.direction[1] + @viewport_half_width * player.direction_normal[1] ]
    end

    def left_frustum_bound(player)
      [ player.position[0] + @focal * player.direction[0] - @viewport_half_width * player.direction_normal[0],
        player.position[1] + @focal * player.direction[1] - @viewport_half_width * player.direction_normal[1] ]
    end

    def horizontal_ray_casting_setup(map,player,ray)
      if ray[1] == 0.0 then
        { start: nil, delta: nil }

      else
        if ray[1] > 0.0 then
          first_line_y  = player.position[1].floor.to_i - ( player.position[1].to_i % @texture_size ) + @texture_size
          direction     = 1.0
          v_epsilon     = EPSILON

        else
          first_line_y  = player.position[1].floor.to_i - ( player.position[1].to_i % @texture_size )
          direction     = -1.0
          v_epsilon     = -EPSILON

        end

        h_epsilon       = ray[0] > 0.0 ? EPSILON : -EPSILON
        first_line_x    = player.position[0] + ( first_line_y - player.position[1] ) * ray[0] / ray[1];
        intersection    = [ first_line_x + h_epsilon, first_line_y + v_epsilon ]

        if is_outside_map?(map, intersection) then
          { start: nil, delta: nil }

        else
          delta = [ @texture_size * direction * ( ray[0] / ray[1] ),
                    @texture_size * direction ]
          { start: intersection, delta: delta }

        end
      end
    end

    def horizontal_ray_casting(map,player,start,delta)
      return NO_HIT if start.nil?

      intersection  = start
      texture       = map.texture_at(*start)

      while map.is_empty_at?(*intersection) || map.has_door_at?(*intersection) do

        if map.has_door_at?(*intersection) then
          half_delta    = delta.mul(0.5)
          door_intersection  = intersection.add half_delta

          if  map.cell_x(intersection) == map.cell_x(door_intersection) &&
              door_intersection[0] % @texture_size < map.cell_at(*intersection)[:door_offset] then
              return  { distance:       Trigo::magnitude(player.position, door_intersection),
                        intersection:   door_intersection,
                        texture:        map.texture_at(*door_intersection),
                        texture_select: 0,
                        texture_offset: door_intersection[0].to_i % @texture_size + @texture_size - map.cell_at(*intersection)[:door_offset],
                        from:           :horizontal_ray_casting_through_door_DOOR_method }
          else
            intersection = intersection.add(delta)
          end
        else
          intersection = intersection.add(delta)
        end

        return NO_HIT if is_outside_map?(map, intersection)

      end

      adjacent_tile_position  = intersection.add( [ 0.0, -delta[1].to_i.sign * @texture_size ] )
      if map.has_door_at?(*adjacent_tile_position) then
        texture         = map.texture_at(*adjacent_tile_position)
        texture_select  = @texture_size
      else
        texture         = map.texture_at(*intersection)
        texture_select  = 0
      end

      { distance:       Trigo::magnitude(player.position, intersection),
        intersection:   intersection,
        texture:        texture,
        texture_select: texture_select,
        texture_offset: intersection[0].to_i % @texture_size,
        from:           :horizontal_ray_casting_method }
    end

    def vertical_ray_casting_setup(map,player,ray)
      if ray[0] == 0.0 then
        { start: nil, delta: nil }

      else
        if ray[0] > 0.0 then
          first_line_x  = player.position[0].floor.to_i - ( player.position[0].to_i % @texture_size ) + @texture_size
          direction     = 1.0
          h_epsilon     = EPSILON

        else
          first_line_x  = player.position[0].floor.to_i - ( player.position[0].to_i % @texture_size )
          direction     = -1.0
          h_epsilon     = -EPSILON

        end

        v_epsilon       = ray[1] > 0.0 ? EPSILON : -EPSILON
        first_line_y    = player.position[1] + ( first_line_x - player.position[0] ) * ray[1] / ray[0]
        intersection    = [ first_line_x + h_epsilon, first_line_y + v_epsilon ]

        if is_outside_map?(map, intersection) then
          { start: nil, delta: nil }

        else
          delta = [ @texture_size * direction,
                    @texture_size * direction * ( ray[1] / ray[0] ) ]
          { start: intersection, delta: delta }
        end
      end
    end

    def vertical_ray_casting(map,player,start,delta)
      return NO_HIT if start.nil?

      intersection  = start
      texture       = map.texture_at(*start)

      while map.is_empty_at?(*intersection) || map.has_door_at?(*intersection) do

        if map.has_door_at?(*intersection) then
          half_delta        = delta.mul(0.5)
          door_intersection = intersection.add half_delta

          if  map.cell_y(intersection) == map.cell_y(door_intersection) &&
              door_intersection[1] % @texture_size < map.cell_at(*intersection)[:door_offset] then
              return  { distance:       Trigo::magnitude(player.position, door_intersection),
                        intersection:   door_intersection,
                        texture:        map.texture_at(*door_intersection),
                        texture_select: 0,
                        texture_offset: door_intersection[1].to_i % @texture_size + @texture_size - map.cell_at(*intersection)[:door_offset],
                        from:           :vertical_ray_casting_through_door_DOOR_method }
          else
            intersection = intersection.add(delta)
          end
        else
          intersection = intersection.add(delta)
        end

        return NO_HIT if is_outside_map?(map, intersection)

      end

      adjacent_tile_position  = intersection.add( [ -delta[0].to_i.sign * @texture_size, 0.0 ] )
      if map.has_door_at?(*adjacent_tile_position) then
        texture         = map.texture_at(*adjacent_tile_position)
        texture_select  = @texture_size
      else
        texture         = map.texture_at(*intersection)
        texture_select  = 0
      end

      { distance:       Trigo::magnitude(player.position, intersection),
        intersection:   intersection,
        texture:        texture,
        texture_select: texture_select,
        texture_offset: intersection[1].to_i % @texture_size,
        from:           :vertical_ray_casting_method }
    end

    def is_outside_map?(map,intersection)
      intersection[0] < 0.0 || intersection[0] >= map.pixel_width || intersection[1] <  0.0 || intersection[1] >= map.pixel_height
    end


    # ---=== ENTITIES RENDERING : ===---
    def render_entities(player,entities)
      in_frustum_entities = cull_out_of_frustum_entities player, entities
      z_sorted_entities   = in_frustum_entities.sort { |e1,e2| e2.view_position[1] <=> e1.view_position[1] }
      scan_textures_for z_sorted_entities
    end

    def cull_out_of_frustum_entities(player,entities)
      entities.select do |entity|
        entity.compute_view_position player

        half_width  = entity.texture.half_width
        left_bound  = entity.view_position.sub(player.direction_normal.mul(half_width))
        right_bound = entity.view_position.add(player.direction_normal.mul(half_width))

        point_in_frustum?(left_bound) || point_in_frustum?(right_bound) 
      end
    end

    def point_in_frustum?(point)
      point[1] > @near && point[0] < @far && ( point[1].to_f / point[0] ).abs > @frustum_slope 
    end

    def scan_textures_for(entities)
      entities.each do |entity|
        # Scanning parameters :
        projected_left_bound  =  @viewport_half_width - ( @viewport_half_width * ( entity.view_position[0] + entity.texture.half_width ).to_f / entity.view_position[1] ).to_i
        projected_right_bound =  @viewport_half_width - ( @viewport_half_width * ( entity.view_position[0] - entity.texture.half_width ).to_f / entity.view_position[1] ).to_i
        projected_width       = projected_right_bound - projected_left_bound 
        texture_step          = entity.texture.width.to_f / projected_width

        # Clipping :
        projected_left_bound  = [ 0, projected_left_bound ].max
        projected_right_bound = [ projected_right_bound, @viewport_width - 1 ].min

        # Scanning :
        projected_left_bound.upto(projected_right_bound) do |x|
          if entity.view_position[1] < @columns[x].first[:distance] then  # the first element of a hit is ALWAYS a wall
            height  = @viewport_texture_factor / ( entity.view_position[1] * @fisheye_correction_factors[x] )
            @columns[x] <<  { distance:       entity.view_position[1],
                              texture:        entity.texture.path,
                              texture_select: 0,
                              texture_offset: ( ( x - projected_left_bound ) * texture_step ).round,
                              height:         height }
          end
        end
      end
    end


    # ---=== SERIALIZATION : ===---
    def serialize
      { viewport_width:   viewport_width,
        viewport_height:  viewport_height,
        focal:            focal,
        near:             near,
        far:              far }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

  end
end
