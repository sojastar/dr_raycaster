module RayCaster
  class Renderer
    EPSILON =  0.1

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

      @hits                       = []

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

      @hits
    end


    # ---=== WALL RENDERING : ===---
    def cast_wall_rays(player,map)
      ray_end = right_frustum_bound player

      @viewport_width.times do |ray_index|
        h_hit = ray_horizontal_intersection map, player, ray_end.sub(player.position)
        v_hit = ray_vertical_intersection   map, player, ray_end.sub(player.position)

        if    h_hit[:texture].nil?                then  @hits[ray_index] = [ v_hit ]
        elsif v_hit[:texture].nil?                then  @hits[ray_index] = [ h_hit ]
        elsif h_hit[:distance] > v_hit[:distance] then  @hits[ray_index] = [ v_hit ]
        else                                            @hits[ray_index] = [ h_hit ]
        end

        @hits[ray_index].first[:height]  = @viewport_texture_factor / ( @hits[ray_index].first[:distance] * @fisheye_correction_factors[ray_index] )   # the wall is ALWAYS the FIRST layer of a column/slice

        ray_end = ray_end.sub(player.direction_normal)
      end

      @hits
    end

    def right_frustum_bound(player)
      [ player.position[0] + @focal * player.direction[0] + @viewport_half_width * player.direction_normal[0],
        player.position[1] + @focal * player.direction[1] + @viewport_half_width * player.direction_normal[1] ]
    end

    def left_frustum_bound(player)
      [ player.position[0] + @focal * player.direction[0] - @viewport_half_width * player.direction_normal[0],
        player.position[1] + @focal * player.direction[1] - @viewport_half_width * player.direction_normal[1] ]
    end

    def ray_horizontal_intersection(map,player,ray)
      if ray[1] == 0.0 then
        distance        = -1.0
        intersection    = [0.0, 0.0]
        texture         = nil
        texture_offset  = 0

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
          intersection  = [0.0, 0.0]
          texture       = nil

        else
          delta = [ @texture_size * direction * ( ray[0] / ray[1] ),
                    @texture_size * direction ]
          texture = map.texture_at(*intersection)
          while texture.nil? do
          #while map.is_empty_at?(*intersection) do
            intersection = intersection.add(delta)

            if is_outside_map?(map, intersection) then
              intersection  = [0.0, 0.0]
              texture       = nil
              break
            end

            texture = map.texture_at(*intersection)
          end
        end 

        #texture         = map.texture_at(*intersection) # new
        distance        = Trigo::magnitude(player.position, intersection)
        texture_offset  = intersection[0].to_i % @texture_size

      end

      { distance:       distance,
        intersection:   intersection,
        texture:        texture,
        texture_offset: texture_offset  }
    end

    def ray_vertical_intersection(map,player,ray)
      if ray[0] == 0.0 then
        distance        = -1.0
        intersection    = [0.0, 0.0]
        texture         = nil
        texture_offset  = 0

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

        v_epsilon     = ray[1] > 0.0 ? EPSILON : -EPSILON
        first_line_y  = player.position[1] + ( first_line_x - player.position[0] ) * ray[1] / ray[0]
        intersection  = [ first_line_x + h_epsilon, first_line_y + v_epsilon ]
        
        if is_outside_map?(map, intersection) then
          intersection  = [0.0, 0.0]
          texture       = nil

        else
          delta = [ @texture_size * direction,
                    @texture_size * direction * ( ray[1] / ray[0] ) ]
          texture = map.texture_at(*intersection)
          while texture.nil? do
          #while map.is_empty_at?(*intersection) do
            intersection = intersection.add(delta)

            if is_outside_map?(map, intersection) then
              intersection  = [0.0, 0.0];
              texture       = nil
              break
            end

            texture = map.texture_at(*intersection)
          end
        end

        #texture         = map.texture_at(*intersection)
        distance        = Trigo::magnitude(player.position, intersection)
        texture_offset  = intersection[1].to_i % @texture_size
      end

      { distance:       distance,
        intersection:   intersection,
        texture:        texture,
        texture_offset: texture_offset  }
    end

    def is_outside_map?(map,intersection)
      intersection[0] < 0.0 || intersection[0] >= map.pixel_width || intersection[1] <  0.0 || intersection[1] >= map.pixel_height
    end


    # ---=== ENTITIES RENDERING : ===---
    def render_entities(player,entities)
      in_frustum_entities = cull_out_of_frustum_entities player, entities

      z_sorted_entities   = in_frustum_entities.sort { |e1,e2| e1.view_position[1] <=> e2.view_position[1] }

      #@sprite_hits.clear
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
          if entity.view_position[1] < @hits[x].first[:distance] then  # the first element of a hit is ALWAYS a wall
            height  = @viewport_texture_factor / ( entity.view_position[1] * @fisheye_correction_factors[x] )
            @hits[x] << { distance:       entity.view_position[1],
                          texture:        entity.texture.path,
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
