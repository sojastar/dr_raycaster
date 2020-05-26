module RayCaster
  class Player
    attr_accessor :position, :direction, :direction_normal

    # ---=== INITIALIZATION : ===---
    def initialize(speed,dampening,angular_speed,texture_size,size,position,start_angle)
      @speed                = speed
      @strafe_speed         = 0.0
      @forward_speed        = 0.0

      @dampening            = dampening

      @angular_speed        = angular_speed.to_radians
      @angle                = start_angle.to_radians

      @size                 = texture_size * size
      @look_ahead           = ( 4.0 * @size / 3.0 ).to_i

      @position             = [ position[0] * texture_size + ( texture_size >> 1 ),
                                position[1] * texture_size + ( texture_size >> 1 ) ]

      @direction            = Trigo::unit_vector_for  @angle
      @direction_normal     = Trigo::normal           @direction

      @strafe_displacement  = [ 0.0, 0.0 ]
      @forward_displacement = [ 0.0, 0.0 ]
    end


    # ---=== UPDATE : ===---
    def update(args,map)
      update_actions  args, map
      update_movement args, map
    end


    # ---=== MOVEMENT : ===---

    # --- Update : ---
    def update_movement(args,map)

      # Rotation :
      dx_mouse  = args.state.last_mouse_position.x - args.inputs.mouse.point.x
      @angle += @angular_speed * dx_mouse if dx_mouse.abs > 2

      @direction        = Trigo::unit_vector_for  @angle
      @direction_normal = Trigo::normal           @direction

      # Translation :
      displacement_is_dirty = false

      # Straff :
      if args.inputs.keyboard.key_held.strafe_left then
        @strafe_speed         = @speed
        @strafe_displacement  = @direction_normal
      elsif args.inputs.keyboard.key_held.strafe_right then
        @strafe_speed         = @speed
        @strafe_displacement  = @direction_normal.inverse
      end

      # Forward / backward :
      if args.inputs.keyboard.key_held.forward then
        @forward_speed        = @speed
        @forward_displacement = @direction
      elsif args.inputs.keyboard.key_held.backward then
        @forward_speed        = @speed
        @forward_displacement = @direction.inverse
      end

      # Clipping to displacement to walls :
      displacement  = @forward_displacement.mul(@forward_speed).add( @strafe_displacement.mul(@strafe_speed) )
      @position     = @position.add [ clip_movement_x(map, displacement),
                                      clip_movement_y(map, displacement) ]
      # Speed dampening :
      @strafe_speed   = if @strafe_speed  > 0.0 then  @strafe_speed - @dampening
                        else                          0.0
                        end
      @forward_speed  = if @forward_speed > 0.0 then  @forward_speed - @dampening
                        else                          0.0
                        end
    end

    # --- Clipping : ---
    def clip_movement_x(map,displacement)
      size_offset           = displacement[0] > 0 ? @size : -@size
      bounding_box_next_x   = @position.add [ displacement[0] + size_offset, 0 ]

      if map.cant_pass_through? *bounding_box_next_x then
        map.texture_size - ( @position[0] % map.texture_size ) - @size
      else
        displacement[0]
      end
    end

    def clip_movement_y(map,displacement)
      size_offset           = displacement[1] > 0 ? @size : -@size
      bounding_box_next_y   = @position.add [ 0, displacement[1] + size_offset ]

      if map.cant_pass_through? *bounding_box_next_y then
        map.texture_size - ( @position[1] % map.texture_size ) - @size
      else
        displacement[1]
      end
    end


    # ---=== ACTIONS : ===---
    def update_actions(args,map)
      if  args.inputs.keyboard.key_down.action1
        looking_at  = @position.add(@direction.mul(@look_ahead))
        cell        = map.cell_at(*looking_at)
        operate_door_at(cell) if cell[:is_door]
      end
    end

    def operate_door_at(cell)
      if    cell[:status] == :closed || cell[:status] == :closing then
        cell[:status] = :opening
      elsif cell[:status] == :open   || cell[:status] == :opening then
        cell[:status] = :closing
      end
    end


    # ---=== SERIALIZATION : ===---
    def serialize
      { current_speed:  @current_speed,
        position:       @position,
        direction:      @direction }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end
