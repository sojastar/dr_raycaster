module RayCaster
  class Player
    attr_accessor :position, :direction, :direction_normal

    # ---=== INITIALIZATION : ===---
    def initialize(speed,dampening,angular_speed,size,position,start_angle)
      @speed              = speed
      @current_speed      = 0.0

      @dampening          = dampening
      @current_dampening  = dampening

      @angular_speed      = Trigo::deg_to_rad angular_speed
      @angle              = Trigo::deg_to_rad start_angle

      @size               = size

      @position           = position.clone
      @direction          = Trigo::unit_vector_for  @angle
      @direction_normal   = Trigo::normal           @direction
    end


    # ---=== MOVEMENT : ===---

    # --- Update : ---
    def update_movement(args,level)

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
      @position     = @position.add [ clip_movement_x(level, displacement),
                                      clip_movement_y(level, displacement) ]
      
      # Speed dampening :
      @current_speed -= @current_dampening if @current_speed != 0
    end

    # --- Clipping : ---
    def clip_movement_x(level,displacement)
      size_offset           = displacement[0] > 0 ? @size : -@size
      bounding_box_next_x   = @position.add [ displacement[0] + size_offset, 0 ]
      if level.has_wall_at? *bounding_box_next_x then
        level.texture_size - ( @position[0] % level.texture_size ) - @size
      else
        displacement[0]
      end
    end

    def clip_movement_y(level,displacement)
      size_offset           = displacement[1] > 0 ? @size : -@size
      bounding_box_next_y   = @position.add [ 0, displacement[1] + size_offset ]
      if level.has_wall_at? *bounding_box_next_y then
        level.texture_size - ( @position[1] % level.texture_size ) - @size
      else
        displacement[1]
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
