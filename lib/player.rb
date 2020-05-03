module RayCaster
  class Player
    attr_accessor :position, :direction, :direction_normal

    def initialize(speed,dampening,angular_speed,position,start_angle)
      @speed              = speed
      @current_speed      = 0.0

      @dampening          = dampening
      @current_dampening  = dampening

      @angular_speed      = Trigo::deg_to_rad angular_speed
      @angle              = Trigo::deg_to_rad start_angle

      @position           = position.clone
      @direction          = Trigo::unit_vector_for  @angle
      @direction_normal   = Trigo::normal           @direction
    end

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

      @position       = @position.add(@direction.mul(@current_speed))
      
      # Speed dampening :
      @current_speed -= @current_dampening if @current_speed != 0
    end

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
