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
  args.gtk.log_level = :off

  # --- Textures : ---
  textures              =   { basic_wall:   RayCaster::Texture.new( 'textures/basic_wall.png',    32 ),
                              plant_wall:   RayCaster::Texture.new( 'textures/plant_wall.png',    32 ),
                              leaking_wall: RayCaster::Texture.new( 'textures/leaking_wall.png',  32 ),
                              rocks:        RayCaster::Texture.new( 'textures/rocks.png',         32 ),
                              door:         RayCaster::Texture.new( 'textures/door.png',          32 ),
                              stone:        RayCaster::Texture.new( 'textures/stone.png',          8 ),
                              skull:        RayCaster::Texture.new( 'textures/skull.png',          8 ),
                              spider_web:   RayCaster::Texture.new( 'textures/spider_web.png',    16 ),
                              slime:        RayCaster::Texture.new( 'textures/slime.png',         32 ),
                              brazier:      RayCaster::Texture.new( 'textures/brazier.png',        8 ) }

  # --- Map : ---
  cells                 = [ [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:t1,:t1,:t1,:t1,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:t1,:t1,:t1,:t1,:t1,:t1,:do,:t1,:t1,:t1,:t1,:t1,:t1],
                            [:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:t1],
                            [:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:do,:te,:te,:te,:do,:te,:te,:te,:t1],
                            [:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:t1],
                            [:te,:te,:te,:te,:te,:te,:t1,:t1,:t1,:t1,:t1,:te,:te,:te,:t1,:t1,:t1,:t1,:t1],
                            [:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:t1],
                            [:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:do,:te,:te,:te,:do,:te,:te,:te,:t1],
                            [:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:t1],
                            [:te,:te,:te,:te,:te,:te,:t1,:t1,:t1,:t1,:t1,:t1,:do,:t1,:t1,:t1,:t1,:t1,:t1],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:t1,:t1,:t1,:te,:te,:te,:t1,:t1,:t1,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:te],
                            [:t1,:ro,:t1,:t1,:t1,:t1,:t1,:t1,:t1,:te,:te,:te,:te,:te,:te,:te,:t1,:t1,:te],
                            [:ro,:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:t1,:te,:te,:te,:t1,:te],
                            [:ro,:ro,:te,:te,:te,:te,:te,:do,:te,:te,:te,:te,:t1,:te,:te,:te,:ro,:ro,:te],
                            [:te,:ro,:ro,:te,:ro,:te,:te,:t1,:te,:te,:te,:t1,:te,:t1,:te,:te,:ro,:ro,:te],
                            [:te,:te,:t1,:t1,:t1,:t1,:t1,:t1,:t1,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:te,:te,:te,:te,:t1,:t1,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:t1,:t1,:t1,:te,:te,:te,:t1,:t1,:t1,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:t1,:do,:t1,:t1,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:t1,:te,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:t1,:te,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:t1,:te,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:t1,:te,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:t1,:te,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:t1,:te,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:t1,:t1,:te,:te,:te,:te,:te] ]
#  cells                 = [ [:t1,:t2,:t3,:t1,:t2,:t3,:t1,:t2,:t3,:t1,:t2,:t3,:t1,:t2,:t3,:t1,:t2,:t3],
#                            [:t3,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:te,:te,:t1],
#                            [:t2,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t2,:te,:te,:te,:te,:te,:t2],
#                            [:t1,:te,:te,:te,:te,:ro,:te,:te,:te,:te,:te,:do,:te,:te,:te,:te,:te,:t3],
#                            [:t3,:te,:te,:te,:te,:t3,:te,:te,:te,:te,:te,:t3,:te,:te,:te,:te,:te,:t1],
#                            [:t2,:te,:te,:te,:te,:t2,:te,:te,:te,:te,:te,:t2,:te,:te,:te,:te,:te,:t2],
#                            [:t1,:te,:t1,:t3,:t2,:t1,:t2,:t3,:t1,:te,:te,:t1,:t2,:t3,:do,:t2,:te,:t3],
#                            [:t3,:te,:te,:te,:te,:t2,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1],
#                            [:t2,:te,:te,:te,:te,:t3,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t2],
#                            [:t1,:te,:te,:te,:te,:t1,:te,:te,:te,:t3,:te,:t2,:te,:te,:te,:te,:te,:t3],
#                            [:t3,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:te,:te,:te,:t1],
#                            [:t2,:te,:te,:te,:te,:te,:te,:te,:te,:t2,:te,:t3,:te,:te,:te,:te,:te,:t2],
#                            [:t1,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t3],
#                            [:t3,:t2,:t1,:t3,:t2,:t1,:t3,:t2,:t1,:t3,:t2,:t1,:t3,:t2,:t1,:t3,:t2,:t1] ]
  blocks                = { te: { texture: nil,                     is_door: false },
                            t1: { texture: textures[:basic_wall],   is_door: false },
                            t2: { texture: textures[:plant_wall],   is_door: false },
                            t3: { texture: textures[:leaking_wall], is_door: false },
                            ro: { texture: textures[:rocks],        is_door: false },
                            do: { texture: textures[:door],         is_door: true  } }
  start_x               = 12#2
  start_y               = 1#2
  args.state.map        = RayCaster::Map.new( cells,
                                              blocks,
                                              textures,
                                              start_x,
                                              start_y )

  # --- Entities : ---
  models                = { stone:      { texture: textures[:stone],      colide: false, other_param: 'for later' },
                            skull:      { texture: textures[:skull],      colide: false, other_param: 'for later' },
                            spider_web: { texture: textures[:spider_web], colide: false, other_param: 'for later' },
                            slime:      { texture: textures[:slime],      colide: false, other_param: 'for later' },
                            brazier:    { texture: textures[:brazier],    colide: false, other_param: 'for later' } }

  # --- Scene : ---
  placements            = [ { model: :brazier,    position: [12, 2] },
                            { model: :skull,      position: [13, 3] },
                            { model: :stone,      position: [ 7, 5] },
                            { model: :brazier,    position: [16, 6] },
                            { model: :brazier,    position: [12, 6] },
                            { model: :brazier,    position: [ 7, 6] },
                            { model: :skull,      position: [17, 7] },
                            { model: :stone,      position: [11, 7] },
                            { model: :brazier,    position: [12, 8] },
                            { model: :stone,      position: [13, 9] },
                            { model: :skull,      position: [ 8, 9] },
                            { model: :brazier,    position: [16,10] },
                            { model: :brazier,    position: [12,10] },
                            { model: :brazier,    position: [ 8,10] },
                            { model: :skull,      position: [17,11] },
                            { model: :spider_web, position: [13,11] },
                            { model: :spider_web, position: [10,14] },
                            { model: :stone,      position: [15,15] },
                            { model: :stone,      position: [16,16] },
                            { model: :brazier,    position: [12,16] },
                            { model: :stone,      position: [ 6,16] },
                            { model: :stone,      position: [ 3,16] },
                            { model: :stone,      position: [ 1,16] },
                            { model: :stone,      position: [14,17] },
                            { model: :brazier,    position: [13,17] },
                            { model: :brazier,    position: [11,17] },
                            { model: :stone,      position: [ 5,17] },
                            { model: :stone,      position: [ 4,17] },
                            { model: :skull,      position: [ 2,17] },
                            { model: :brazier,    position: [12,18] },
                            { model: :stone,      position: [ 8,18] },
                            { model: :stone,      position: [ 6,18] },
                            { model: :stone,      position: [ 3,18] },
                            { model: :stone,      position: [15,19] },
                            { model: :skull,      position: [10,19] },
                            { model: :skull,      position: [15,20] },
                            { model: :spider_web, position: [13,21] },
                            { model: :spider_web, position: [11,21] } ]
#  placements            = [ { model: :spider_web,  position: [ 1, 1] },
#                            { model: :stone,       position: [ 6, 1] },
#                            { model: :spider_web,  position: [10, 1] },
#                            { model: :stone,       position: [ 2, 3] },
#                            { model: :slime,       position: [14, 3] },
#                            { model: :stone,       position: [ 8, 4] },
#                            { model: :brazier,     position: [ 4, 5] },
#                            { model: :brazier,     position: [ 6, 5] },
#                            { model: :spider_web,  position: [16, 5] },
#                            { model: :stone,       position: [15, 6] },
#                            { model: :brazier,     position: [ 4, 7] },
#                            { model: :brazier,     position: [ 6, 7] },
#                            { model: :stone,       position: [ 2, 9] },
#                            { model: :brazier,     position: [10, 9] },
#                            { model: :skull,       position: [14, 9] },
#                            { model: :brazier,     position: [ 9,10] },
#                            { model: :brazier,     position: [11,10] },
#                            { model: :stone,       position: [ 4,11] },
#                            { model: :brazier,     position: [10,11] },
#                            { model: :spider_web,  position: [ 1,12] },
#                            { model: :spider_web,  position: [16,12] } ]
  args.state.scene      = RayCaster::Scene.new( args.state.map,
                                                models,
                                                placements )


  # --- Player : ---
  args.state.player     = RayCaster::Player.new(  4,                              # speed
                                                  0.25,                           # dampening
                                                  3.0,                            # angular speed
                                                  blocks[:t1][:texture].width,    # texture size
                                                  0.5,                            # size (relative to texture size)
                                                  [ args.state.map.start_x,       # start position x
                                                    args.state.map.start_y ],     # start position y
                                                  90.0 )                          # start angle

  # --- Renderer : ---
  args.state.renderer   = RayCaster::Renderer.new(  VIEWPORT_WIDTH,
                                                    VIEWPORT_HEIGHT,
                                                    FOCAL,
                                                    NEAR,
                                                    FAR,
                                                    blocks[:t1][:texture].width ) # texture size

  # --- Lighting : ---
  compute_lighting(args, 32, 128, 0)

  # --- Miscellenaous : ---
  args.state.mode       = Debug::parse_debug_arg($gtk.argv)

  args.state.setup_done = true
end





# ---=== MAIN LOOP : ===---
def tick(args)

  # --- Setup : ---
  setup(args) unless args.state.setup_done

  # --- Update : ---
  args.state.player.update  args, args.state.map
  args.state.scene.update   args, args.state.player

  args.state.mode = ( args.state.mode + 1 ) % 2 if args.inputs.keyboard.key_down.space

  # --- Render : ---
  columns = args.state.renderer.render  args.state.scene,
                                        args.state.player

  # --- Draw : ---
  #if args.state.debug == 0 || args.state.debug.nil? then
  if args.state.mode == 0 || args.state.mode.nil? then
    args.outputs.solids  << [ [0,   0, 1279, 359, 40, 40, 40, 255],
                              [0, 360, 1279, 720, 50, 50, 50, 255] ]

    args.outputs.sprites << columns.map.with_index do |column,index|
                              column.map do |layer|
                                unless layer[:texture].nil? then
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
                                    tile_x: layer[:texture_offset] + layer[:texture_select],
                                    tile_y: 0,
                                    tile_w: 1,
                                    tile_h: 32 }
                                end
                              end
                            end

  #elsif args.state.debug == 1 then
  elsif args.state.mode == 1 then
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

