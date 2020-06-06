module RayCaster
  class Texture
    attr_reader :path,
                :width, :half_width,
                :offset,
                :frame_index, :current_clip,
                :tile_x, :tile_y,
                :flip_x, :flip_y


    # --- INITIALIZATION : ---
    def initialize(path,width,height,clips=nil,start_frame=-1)
      @path       = path

      @width        = width
      @height       = height

      @half_width   = width >> 1
      @offset       = 0

      @clips        = clips
      if @clips.nil? then
        @current_clip = nil
        @max_frame    = -1
        @frame_index  = 0
        @mode         = -1
        @tile_x       = 0
        @tile_y       = 0
        @flip_x       = false
        @flip_y       = false
      else
        @current_clip = @clips[@clips.keys.first]
        @max_frame    = @current_clip[:frames].length - 1
        @frame_index  = start_frame == -1 ? rand(@max_frame) : start_frame
        @mode         = @current_clip[:mode]
        @tile_x       = @current_clip[:frames][0][0] * @width
        @tile_y       = @current_clip[:frames][0][1] * @height
        @flip_x       = @current_clip[:flip_x]
        @flip_y       = @current_clip[:flip_y]
      end

      @count_dir    = :up
      @tick         = 0
    end

    def clone
      Texture.new @path, @width, @height, @clips
    end


    # --- ANIMATION : ---
    def is_animated?
      !@clips.nil?
    end

    def reset_clip
      @frame_index  = 0
      @tick         = 0
      @tile_x       = @current_clip[:frames][0][0] * @width
      @tile_y       = @current_clip[:frames][0][1] * @height
    end

    def set_clip(clip,start_frame=-1)
      @current_clip = @clips[clip]
      @max_frame    = @current_clip[:frames].length - 1
      @frame_index  = start_frame == -1 ? rand(@max_frame) : start_frame
      @mode         = @current_clip[:mode] 
      @tile_x       = @current_clip[:frames][0][0] * @width
      @tile_y       = @current_clip[:frames][0][1] * @height
      @flip_x       = @current_clip[:flip_x]
      @flip_y       = @current_clip[:flip_y]
    end

    def set_frame(frame_index)
      @tick         = 0
      @frame_index  = frame_index < @max_frame ? frame_index : @max_frame
    end

    def update
      @tick = ( @tick + 1 ) % @current_clip[:speed]

      if @tick == 0 then
        case @current_clip[:mode]
        when :single
          @frame_index += 1
          @frame_index  = @max_frame if @frame_index >= @max_frame

        when :loop
          @frame_index  = ( @frame_index + 1 ) % @max_frame

        when :pingpong
          if @count_dir == :up then
            @frame_index += 1
            @count_dir    = :down   if @frame_index == @max_frame

          elsif @count_dir == :down then
            @frame_index -= 1
            @count_dir    = :up   if @frame_index == 0

          end

        end 
      end

      @tile_x       = @current_clip[:frames][@frame_index][0] * @width
      @tile_y       = @current_clip[:frames][@frame_index][1] * @height
    end


    # --- SERIALIZATION : ---
    def serialize
      { path: @path, width: @width, height: @height, offset: @offset, is_animated: is_animated? }
    end

    def inspect
      serialize.to_s
    end

    def to_s
      serialize.to_s
    end
  end
end

