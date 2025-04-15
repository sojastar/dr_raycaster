module RayCaster
  class Texture
    attr_reader :path,
                :width, :half_width,
                :offset,
                :frame_index, :current_clip,
                :flip_x, :flip_y,
                :source_x, :source_y,
                :frames, :is_animated


    # --- INITIALIZATION : ---
    def initialize(path,width,height,frames,mode,speed)
      @path = path

      @width      = width
      @half_width = width >> 1
      @height     = height

      @frames       = frames
      @max_frame    = frames.length == 1 ? -1 : frames.length - 1
      @frame_index  = 0
      @mode         = mode.nil? ? :not_animated : mode
      @speed        = speed
      @source_x     = @frames[0][0] * @width
      @source_y     = @frames[0][1] * @height
      @flip_x       = false
      @flip_y       = false

      @is_animated  = frames.length > 1
      @count_dir    = :up
      @tick         = 0
    end

    def clone
      Texture.new @path,
                  @width,
                  @height,
                  @frames, 
                  ( @mode == :not_animated ? nil : @mode ),
                  @speed
    end


    # --- ANIMATION : ---
    def set_frame(frame_index)
      @tick         = 0
      @frame_index  = frame_index < @max_frame ? frame_index : @max_frame
    end

    def update
      @tick = ( @tick + 1 ) % @speed

      if @tick == 0 then
        case @mode
        when :single
          @frame_index += 1
          @frame_index  = @max_frame if @frame_index >= @max_frame

        when :loop
          @frame_index  = ( @frame_index + 1 ) % @max_frame

        when :pingpong
          if @count_dir == :up then
            @frame_index += 1
            @count_dir    = :down   if @frame_index == @max_frame - 1

          elsif @count_dir == :down then
            @frame_index -= 1
            @count_dir    = :up   if @frame_index == 0

          end

        end 
      end

      #@tile_x = @frames[@frame_index][0] * @width
      #@tile_y = @frames[@frame_index][1] * @height
      @source_x = @frames[@frame_index][0] * @width
      @source_y = @frames[@frame_index][1] * @height
    end


    # --- SERIALIZATION : ---
    def serialize
      { path: @path, width: @width, height: @height, is_animated: @is_animated, source_x: @source_x, source_y: @source_y }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end

