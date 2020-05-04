require 'lib/debug.rb'
require 'lib/extend_array.rb'
require 'lib/trigo.rb'
require 'lib/texture.rb'
require 'lib/map.rb'
require 'lib/entity.rb'
require 'lib/scene.rb'
require 'lib/renderer.rb'
require 'lib/player.rb'





# ---=== CONSTANTS : ===---
VIEWPORT_WIDTH  = 160
VIEWPORT_HEIGHT = 90
FOCAL           = 80




# ---=== SETUP : ===---
def setup(args)
  # --- Textures : ---
  textures              =   { basic_wall:   RayCaster::Texture.new( 'textures/basic_wall.png',    32 ),
                              plant_wall:   RayCaster::Texture.new( 'textures/plant_wall.png',    32 ),
                              leaking_wall: RayCaster::Texture.new( 'textures/leaking_wall.png',  32 ),
                              door:         RayCaster::Texture.new( 'textures/door.png',          32 ),
                              stone:        RayCaster::Texture.new( 'textures/stone.png',          8 ),
                              skull:        RayCaster::Texture.new( 'textures/skull.png',          8 ),
                              spider_web:   RayCaster::Texture.new( 'textures/spider_web.png',    16 ),
                              brazier:      RayCaster::Texture.new( 'textures/brazier.png',        8 ) }

  # --- Map : ---
  cells                 = [ [:t1,:t2,:t3,:t1,:t2,:t3,:t1,:t2,:t3,:t1,:t2,:t3,:t1,:t2,:t3,:t1,:t2,:t3],
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
  blocks                = { te: { texture: nil,                     other_param: 'for later' },
                            t1: { texture: textures[:basic_wall],   other_param: 'for later' },
                            t2: { texture: textures[:plant_wall],   other_param: 'for later' },
                            t3: { texture: textures[:leaking_wall], other_param: 'for later' },
                            do: { texture: textures[:door],         other_param: 'for later' } }   
  start_x               = 3
  start_y               = 3
  args.state.map        = RayCaster::Map.new( cells,
                                              blocks,
                                              textures,
                                              start_x,
                                              start_y )

  # --- Entities : ---
  models                = { stone:       { texture: :stone,       colide: false, other_param: 'for later' },
                            skull:       { texture: :skull,       colide: false, other_param: 'for later' },
                            spider_web:  { texture: :spider_web,  colide: false, other_param: 'for later' },
                            brazier:     { texture: :brazier,     colide: false, other_param: 'for later' } }

  # --- Scene : ---
  placements            = [ { model: :spider_web, position: [4,5], other_param: 'for later' } ]
  args.state.scene      = RayCaster::Scene.new( args.state.map,
                                                models,
                                                placements )
  puts args.state.scene.entities
    

  # --- Player : ---
  args.state.player     = RayCaster::Player.new(  8,                                                        # speed
                                                  1,                                                        # dampening
                                                  3.0,                                                      # angular speed
                                                  blocks[:t1][:texture].width >> 1,                         # size
                                                  [ blocks[:t1][:texture].width* args.state.map.start_x,    # start position x
                                                    blocks[:t1][:texture].width* args.state.map.start_y ],  # start position y
                                                  0.0 )                                                     # start angle

  # --- Renderer : ---
  args.state.renderer   = RayCaster::Renderer.new(  VIEWPORT_WIDTH,
                                                    VIEWPORT_HEIGHT,
                                                    FOCAL,
                                                    blocks[:t1][:texture].width ) # texture size

  # --- Lighting : ---
  compute_lighting(args, 32, 192, 0)

  args.state.setup_done = true
end





# ---=== MAIN LOOP : ===---
def tick(args)

  # --- Setup : ---
  setup(args) unless args.state.setup_done

  # --- Update : ---
  args.state.player.update_movement args, args.state.map

  # --- Render : ---
  columns = args.state.renderer.render  args.state.scene,
                                        args.state.player

  args.outputs.solids  << [ [0,   0, 1279, 359, 90, 90, 90, 255],
                            [0, 360, 1279, 720, 50, 50, 50, 255] ]  
  args.outputs.sprites << columns.map.with_index do |column,index|
                            rectified_height  = column[:height].to_i * 12
                            lighting          = lighting_at args, column[:distance].to_i
                            { x:      index * 8,                            # 8 = 1280 / 160
                              y:      ( 720 - rectified_height ) >> 1,
                              w:      8,
                              h:      rectified_height,
                              path:   column[:texture],
                              r:      lighting,
                              g:      lighting,
                              b:      lighting,
                              tile_x: column[:texture_offset],
                              tile_y: 0,
                              tile_w: 1,
                              tile_h: 32 } 
                          end
end





# --- LIGHTING : ---
def compute_lighting(args,full_light_distance,min_light_distance,min_light)
  # Bounds :
  args.state.lighting                       = {}
  args.state.lighting[:full_light_distance] = full_light_distance
  args.state.lighting[:min_light_distance]  = min_light_distance
  args.state.lighting[:min_light]           = min_light
  
  # Gradient :
  args.state.lighting[:gradient]            = []
  a = ( 255.0 - min_light ) / ( full_light_distance - min_light_distance )
  b = 255 - a * full_light_distance
  min_light_distance.times do |distance|
    if distance < full_light_distance then
      args.state.lighting[:gradient][distance]  = 255
    else
      args.state.lighting[:gradient][distance]  = a * distance + b
    end
  end
end

def lighting_at(args,distance)
  distance < args.state.lighting[:min_light_distance] ? args.state.lighting[:gradient][distance] : args.state.lighting[:min_light]
end





# --- TOOLS : ---
def render_map_top_down(args,map,offset)
  blocks  = []
  map.height.times do |y|
    map.width.times do |x|
      blocks << [ offset[0] + x * 32, offset[1] + y * 32, 32, 32 ] +  case map[x,y][:type]
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

