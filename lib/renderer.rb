module RayCaster
  class Renderer
    EPSILON =  0.1

    attr_reader :viewport_width, :viewport_height, :focal

    def initialize(viewport_width,viewport_height,focal,texture_size)
      @viewport_width             = viewport_width
      @viewport_half_width        = viewport_width >> 1 
      @viewport_height            = viewport_height
      @viewport_half_height       = viewport_height>> 1 

      @focal                      = focal

      @texture_size               = texture_size

      @wall_hits                  = Array.new(@viewport_width) 

      @fisheye_correction_factors = @viewport_width.times.map do |i|
                                      p1 = [ i - viewport_width / 2, @focal ]
                                      p2 = [ 0.0, 0.0 ]

                                      1.5 * @focal / Trigo::magnitude(p1, p2)
                                    end
    end

    def render(player,level)
      cast_wall_rays level, player
    end

    def cast_wall_rays(player,level)
      ray_end = right_frustum_bound player

      @viewport_width.times do |ray_index|
      #30.times do |ray_index|
        h_hit = ray_horizontal_intersection level, player, ray_end.sub(player.position)
        v_hit = ray_vertical_intersection   level, player, ray_end.sub(player.position)

        if    h_hit[:texture].nil?                then  @wall_hits[ray_index] = v_hit
        elsif v_hit[:texture].nil?                then  @wall_hits[ray_index] = h_hit
        elsif h_hit[:distance] > v_hit[:distance] then  @wall_hits[ray_index] = v_hit
        else                                            @wall_hits[ray_index] = h_hit
        end

        @wall_hits[ray_index][:height]  = ( @viewport_height * @texture_size ) /
                                          ( @wall_hits[ray_index][:distance] * @fisheye_correction_factors[ray_index] )

        ray_end = ray_end.sub(player.direction_normal)
      end

      @wall_hits
    end

    def right_frustum_bound(player)
      [ player.position[0] + @focal * player.direction[0] + @viewport_half_width * player.direction_normal[0],
        player.position[1] + @focal * player.direction[1] + @viewport_half_width * player.direction_normal[1] ]
    end

    def ray_horizontal_intersection(level,player,ray)
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

        if is_outside_map?(level, intersection) then
          intersection  = [0.0, 0.0]
          texture       = nil

        else
          delta = [ @texture_size * direction * ( ray[0] / ray[1] ),
                    @texture_size * direction ]
          texture = level.texture_at(*intersection)
          while texture.nil? do
            intersection = intersection.add(delta)

            if is_outside_map?(level, intersection) then
              intersection  = [0.0, 0.0]
              texture       = nil
              break
            end

            texture = level.texture_at(*intersection)
          end
        end 

          distance        = Trigo::magnitude(player.position, intersection)
          texture_offset  = intersection[0].to_i % @texture_size

      end

      { distance:       distance,
        intersection:   intersection,
        texture:        texture,
        texture_offset: texture_offset  }
    end

    def ray_vertical_intersection(level,player,ray)
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
        
        if is_outside_map?(level, intersection) then
          intersection  = [0.0, 0.0]
          texture       = nil

        else
          delta = [ @texture_size * direction,
                    @texture_size * direction * ( ray[1] / ray[0] ) ]
          texture = level.texture_at(*intersection)
          while texture.nil? do
            intersection = intersection.add(delta)

            if is_outside_map?(level, intersection) then
              intersection  = [0.0, 0.0];
              texture       = nil
              break
            end

            texture = level.texture_at(*intersection)
          end
        end

        distance        = Trigo::magnitude(player.position, intersection)
        texture_offset  = intersection[1].to_i % @texture_size
      end

      { distance:       distance,
        intersection:   intersection,
        texture:        texture,
        texture_offset: texture_offset  }
    end

    def is_outside_map?(level,intersection)
      intersection[0] < 0.0 || intersection[0] >= level.pixel_width || intersection[1] <  0.0 || intersection[1] >= level.pixel_height
    end

    def serialize
      { viewport_width:   viewport_width,
        viewport_height:  viewport_height,
        focal:            focal }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end

  end
end
