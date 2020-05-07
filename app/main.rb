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
NEAR            = 16 
FAR             = 1500




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
  blocks                = { te: { texture: nil,                     is_door: false },
                            t1: { texture: textures[:basic_wall],   is_door: false },
                            t2: { texture: textures[:plant_wall],   is_door: false },
                            t3: { texture: textures[:leaking_wall], is_door: false },
                            do: { texture: textures[:door],         is_door: true  } }
  start_x               = 1
  start_y               = 1
  args.state.map        = RayCaster::Map.new( cells,
                                              blocks,
                                              textures,
                                              start_x,
                                              start_y )

  # --- Entities : ---
  models                = { stone:       { texture: textures[:stone],       colide: false, other_param: 'for later' },
                            skull:       { texture: textures[:skull],       colide: false, other_param: 'for later' },
                            spider_web:  { texture: textures[:spider_web],  colide: false, other_param: 'for later' },
                            brazier:     { texture: textures[:brazier],     colide: false, other_param: 'for later' } }

  # --- Scene : ---
  placements            = [ { model: :spider_web,  position: [ 1, 1] },
                            { model: :stone,       position: [ 6, 1] },
                            { model: :spider_web,  position: [10, 1] },
                            { model: :stone,       position: [ 2, 3] },
                            { model: :skull,       position: [14, 3] },
                            { model: :stone,       position: [ 8, 4] },
                            { model: :brazier,     position: [ 4, 5] },
                            { model: :brazier,     position: [ 6, 5] },
                            { model: :spider_web,  position: [16, 5] },
                            { model: :stone,       position: [15, 6] },
                            { model: :brazier,     position: [ 4, 7] },
                            { model: :brazier,     position: [ 6, 7] },
                            { model: :stone,       position: [ 2, 9] },
                            { model: :brazier,     position: [10, 9] },
                            { model: :skull,       position: [14, 9] },
                            { model: :brazier,     position: [ 9,10] },
                            { model: :brazier,     position: [11,10] },
                            { model: :stone,       position: [ 4,11] },
                            { model: :brazier,     position: [10,11] },
                            { model: :spider_web,  position: [ 1,12] },
                            { model: :spider_web,  position: [16,12] } ]
  args.state.scene      = RayCaster::Scene.new( args.state.map,
                                                models,
                                                placements )


  # --- Player : ---
  args.state.player     = RayCaster::Player.new(  4,                                                        # speed
                                                  0.25,                                                     # dampening
                                                  3.0,                                                      # angular speed
                                                  blocks[:t1][:texture].width >> 1,                         # size
                                                  [ blocks[:t1][:texture].width* args.state.map.start_x,    # start position x
                                                    blocks[:t1][:texture].width* args.state.map.start_y ],  # start position y
                                                  0.0 )                                                     # start angle

  # --- Renderer : ---
  args.state.renderer   = RayCaster::Renderer.new(  VIEWPORT_WIDTH,
                                                    VIEWPORT_HEIGHT,
                                                    FOCAL,
                                                    NEAR,
                                                    FAR,
                                                    blocks[:t1][:texture].width ) # texture size

  # --- Lighting : ---
  compute_lighting(args, 32, 192, 0)

  # --- Miscellenaous : ---
  args.state.debug      = Debug::parse_debug_arg($gtk.argv)

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

  # --- Draw : ---
  if args.state.debug == 0 || args.state.debug.nil? then
    args.outputs.solids  << [ [0,   0, 1279, 359, 40, 40, 40, 255],
                              [0, 360, 1279, 720, 50, 50, 50, 255] ]

    args.outputs.sprites << columns.map.with_index do |column,index|
                              column.map do |layer|
                                rectified_height  = layer[:height].to_i * 12
                                lighting          = lighting_at args, layer[:distance].to_i
                                { x:      index * 8,
                                  y:      ( 720 - rectified_height ) >> 1,
                                  w:      8,
                                  h:      rectified_height,
                                  path:   layer[:texture],
                                  r:      lighting,
                                  g:      lighting,
                                  b:      lighting,
                                  tile_x: layer[:texture_offset],
                                  tile_y: 0,
                                  tile_w: 1,
                                  tile_h: 32 }
                              end
                            #end.flatten
                            end

  elsif args.state.debug == 1 then
    offset_world_space  = [20,100]
    Debug::render_map_top_down     args.state.scene.map,                      offset_world_space
    Debug::render_player_top_down  args.state.player,   args.state.renderer,  offset_world_space
    Debug::render_wall_hits        columns,                                   offset_world_space
    Debug::render_entities         args.state.scene,    args.state.player,    offset_world_space

    #offset_view_space   = [700, 500]
    #Debug::render_view_space                                offset_view_space
    #Debug::render_entities_in_view_space  args.state.scene, offset_view_space 

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

