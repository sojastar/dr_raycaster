module RayCaster
  class Player
    attr_accessor :position, :direction, :direction_normal

    # ---=== INITIALIZATION : ===---
    def initialize(speed,dampening,angular_speed,size,position,start_angle)
      @speed              = speed
      @current_speed      = 0.0

      @dampening          = dampening
      @current_dampening  = dampening

      @angular_speed      = angular_speed.to_radians
      @angle              = start_angle.to_radians

      @size               = size
      @look_ahead         = ( 4.0 * size / 3.0 ).to_i

      @position           = position.clone
      @direction          = Trigo::unit_vector_for  @angle
      @direction_normal   = Trigo::normal           @direction
    end


    # ---=== UPDATE : ===---
    def update(args,map)
      update_actions  args, map
      update_movement args, map
    end


    # ---=== MOVEMENT : ===---

    # --- Update : ---
    def update_movement(args,map)

      # Direction :
      if args.inputs.keyboard.key_held.left then
        @angle += @angular_speed
      elsif args.inputs.keyboard.key_held.right then
        @angle -= @angular_speed
      end

      @direction        = Trigo::unit_vector_for  @angle
      @direction_normal = Trigo::normal           @direction

      # Position :
      if args.inputs.keyboard.key_held.up then
        @current_speed      = @speed
        @current_dampening  = @dampening
      elsif args.inputs.keyboard.key_held.down then
        @current_speed      = -@speed
        @current_dampening  = -@dampening
      end

      displacement  = @direction.mul(@current_speed)
      @position     = @position.add [ clip_movement_x(map, displacement),
                                      clip_movement_y(map, displacement) ]
      # Speed dampening :
      @current_speed -= @current_dampening if @current_speed != 0
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
      if  args.inputs.keyboard.key_down.e
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
