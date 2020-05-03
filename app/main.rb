require 'lib/debug.rb'
require 'lib/extend_array.rb'
require 'lib/trigo.rb'
require 'lib/renderer.rb'
require 'lib/level.rb'
require 'lib/texture.rb'
require 'lib/player.rb'





# ---=== CONSTANTS : ===---
VIEWPORT_WIDTH  = 160
VIEWPORT_HEIGHT = 90
FOCAL           = 80




# ---=== SETUP : ===---
def setup(args)
  # --- Level : ---
  map     = [ [:t1,:t2,:t3,:t1,:t2,:t3,:t1,:t2,:t3,:t1,:t2,:t3,:t1,:t2,:t3,:t1,:t2,:t3],
              [:t3,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t2,:te,:te,:te,:te,:te,:t1],
              [:t2,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:t1,:t2,:t3,:te,:t2],
              [:t1,:te,:te,:te,:te,:t1,:te,:te,:te,:te,:te,:t3,:te,:t3,:te,:te,:te,:t3],
              [:t3,:te,:te,:te,:te,:t3,:te,:te,:te,:te,:te,:t2,:te,:t2,:t1,:t3,:t2,:t1],
              [:t2,:te,:te,:te,:te,:t2,:te,:te,:te,:te,:te,:t1,:te,:t1,:te,:te,:te,:t2],
              [:t1,:te,:t1,:t3,:t2,:t1,:t2,:t3,:t1,:te,:te,:te,:te,:te,:te,:te,:te,:t3],
              [:t3,:te,:te,:te,:te,:t2,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1],
              [:t2,:te,:te,:te,:te,:t3,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t2],
              [:t1,:te,:te,:te,:te,:t1,:te,:te,:te,:t3,:te,:t2,:te,:te,:te,:te,:te,:t3],
              [:t3,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:te,:te,:te,:t1],
              [:t2,:te,:te,:te,:te,:te,:te,:te,:te,:t2,:te,:t3,:te,:te,:te,:te,:te,:t2],
              [:t1,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t3],
              [:t3,:t2,:t1,:t3,:t2,:t1,:t3,:t2,:t1,:t3,:t2,:t1,:t3,:t2,:t1,:t3,:t2,:t1] ]
  blocks  = { te: { type: 0, texture: nil,                       size: 32 },
              t1: { type: 1, texture: 'textures/basic_wall.png', size: 32 },
              t2: { type: 2, texture: 'textures/wall_plant.png', size: 32 },
              t3: { type: 3, texture: 'textures/wall_leak.png',  size: 32 } }
  start_x = 3
  start_y = 3
  args.state.level      = RayCaster::Level.new( map,
                                                blocks,
                                                start_x,
                                                start_y )

  # --- Player : ---
  args.state.player     = RayCaster::Player.new(  8,                                                  # speed
                                                  1,                                                  # dampening
                                                  3.0,                                                # angular speed
                                                  blocks[:t1][:size] >> 1,                           # size
                                                  [ blocks[:t1][:size] * args.state.level.start_x,   # start position x
                                                    blocks[:t1][:size] * args.state.level.start_y ], # start position y
                                                  0.0 )                                               # start angle

  # --- Renderer : ---
  args.state.renderer   = RayCaster::Renderer.new(  VIEWPORT_WIDTH,
                                                    VIEWPORT_HEIGHT,
                                                    FOCAL,
                                                    blocks[:t1][:size] )   # texture size

  args.state.setup_done = true
end





# ---=== MAIN LOOP : ===---
def tick(args)
  # --- Setup : ---
  setup(args) unless args.state.setup_done

  # --- Update : ---
  args.state.player.update_movement args, args.state.level

  # --- Render : ---
  columns = args.state.renderer.render  args.state.level,
                                        args.state.player
  args.outputs.solids  << [ [0,   0, 1279, 359, 90, 90, 90, 255],
                            [0, 360, 1279, 720, 50, 50, 50, 255] ]  
  args.outputs.sprites << columns.map.with_index do |column,index|
                            rectified_height  = column[:height].to_i * 12
                            #lighting          = column[:disance] > 80 ? 335 - column[:distance] : 255
                            #lighting          = 0 if lighting < 0
                            #lighting = 128
                            { x:      index * 8,                            # 8 = 1280 / 160
                              y:      ( 720 - rectified_height ) >> 1,
                              w:      8,
                              h:      rectified_height,
                              path:   column[:texture],
                              #r:      lighting,
                              #g:      lighting,
                              #b:      lighting,
                              #a:      255,
                              tile_x: column[:texture_offset],
                              tile_y: 0,
                              tile_w: 1,
                              tile_h: 32 } 
                          end
  #render_hits             args, columns,            [200, 200] 
  #render_level_top_down   args, args.state.level,   [200, 200]
  #render_player_top_down  args, args.state.player,  [200, 200]
end





# --- TOOLS : ---
def render_level_top_down(args,level,offset)
  blocks  = []
  level.height.times do |y|
    level.width.times do |x|
      blocks << [ offset[0] + x * 32, offset[1] + y * 32, 32, 32 ] +  case level[x,y][:type]
                                                                      when 0  then [  0,   0,   0, 255]
                                                                      when 1  then [255,   0,   0, 255]
                                                                      when 2  then [  0, 255,   0, 255]
                                                                      when 3  then [  0,   0, 255, 255]
                                                                      end
    end
  end

  args.outputs.solids << blocks
end

def render_player_top_down(args,player,offset)
  x = player.position[0] + offset[0]
  y = player.position[1] + offset[1]
  Debug::draw_cross(player.position.add(offset), 5, [0, 0, 255, 255])

  dx  = 32 * player.direction[0]
  dy  = 32 * player.direction[1]
  args.outputs.lines << [x, y, x + dx, y + dy, 0, 0, 255, 255]
end

def render_hits(args,hits,offset)
  hits.each { |hit| Debug::draw_cross(hit[:intersection].add(offset), 2, [255, 0 ,255, 255]) }
end

