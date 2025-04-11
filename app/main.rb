require 'lib/debug.rb'
require 'lib/extend_array.rb'
require 'lib/trigo.rb'
require 'lib/texture.rb'
require 'lib/map.rb'
require 'lib/cell.rb'
require 'lib/entity.rb'
require 'lib/scene.rb'
require 'lib/renderer.rb'
require 'lib/slice.rb'
require 'lib/keymap.rb'
require 'lib/player.rb'





# ---=== CONSTANTS : ===---

# --- Rendering : ---
VIEWPORT_WIDTH  = 160
VIEWPORT_HEIGHT = 90
FOCAL           = 80
NEAR            = 16
FAR             = 1500

MAX_SPRITES = 500
SLICE_WIDTH = $gtk.args.grid.right / VIEWPORT_WIDTH

MAX_LIGHT = (1 << 8) - 1

# --- Textures : ---
TEXTURE_SIZE  = 1 << 5

TEXTURE_FILE  = 'textures/textures.png'

TEXTURES  = { basic_wall:   { width:  TEXTURE_SIZE,
                              height: TEXTURE_SIZE,
                              frames: [ [ 0, 0 ] ] },
              plant_wall:   { width:  TEXTURE_SIZE,
                              height: TEXTURE_SIZE,
                              frames: [ [ 6, 0 ] ] },
              leaking_wall: { width:  TEXTURE_SIZE,
                              height: TEXTURE_SIZE,
                              frames: [ [ 3, 0 ], [ 4, 0 ], [ 5, 0 ] ],
                              mode:   :loop,
                              speed:  12 },
              rocks:        { width:  TEXTURE_SIZE,
                              height: TEXTURE_SIZE,
                              frames: [ [ 7, 0 ] ] },
              door:         { width:  TEXTURE_SIZE,
                              height: TEXTURE_SIZE,
                              frames: [ [ 1, 0 ] ] },
              stone:        { width:  TEXTURE_SIZE >> 2,
                              height: TEXTURE_SIZE,
                              frames: [ [ 35, 0 ] ] },
              skull:        { width:  TEXTURE_SIZE >> 2,
                              height: TEXTURE_SIZE,
                              frames: [ [ 36, 0 ] ] },
              spider_web:   { width:  TEXTURE_SIZE >> 1,
                              height: TEXTURE_SIZE,
                              frames: [ [ 16, 0 ] ] },
              brazier:      { width:  TEXTURE_SIZE >> 1,
                              height: TEXTURE_SIZE,
                              frames: [ [ 18, 0 ], [ 19, 0 ], [ 20, 0 ] ],
                              mode:   :pingpong,
                              speed:  12 } }

# --- Key Mappings : ---
QWERTY_MAPPING  = { forward:      :w,
                    backward:     :s,
                    strafe_left:  :a,
                    strafe_right: :d,
                    action1:      :e  }

AZERTY_MAPPING  = { forward:      :z,
                    backward:     :s,
                    strafe_left:  :q,
                    strafe_right: :d,
                    action1:      :e  }




# ---=== SETUP : ===---
def setup(args)
  args.gtk.log_level = :off

  # --- Textures : ---
  textures  = TEXTURES.to_a
                      .map { |name,data|
                        [ name,
                          RayCaster::Texture.new( TEXTURE_FILE,
                                                  data[:width],
                                                  data[:height],
                                                  data[:frames],
                                                  data[:mode],
                                                  data[:speed] ) ]
                      }
                      .to_h

  # --- Map : ---
  map                   = [ [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:t1,:t1,:t1,:t1,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:te,:te,:te,:te,:t1,:te,:te,:te,:t1,:te,:te,:te,:te],
                            [:te,:te,:te,:te,:te,:te,:t1,:t1,:t1,:t1,:t1,:t3,:do,:t3,:t1,:t1,:t1,:t1,:t1],
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
  cells                 = { te: RayCaster::Cell.new(nil,                      :empty),
                            t1: RayCaster::Cell.new(textures[:basic_wall],    :wall),
                            t2: RayCaster::Cell.new(textures[:plant_wall],    :wall),
                            t3: RayCaster::Cell.new(textures[:leaking_wall],  :wall),
                            ro: RayCaster::Cell.new(textures[:rocks],         :wall),
                            do: RayCaster::Door.new(textures[:door]) }
  start_x               = 12
  start_y               = 1
  args.state.map        = RayCaster::Map.new( map,
                                              cells,
                                              TEXTURE_SIZE,
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
  args.state.scene      = RayCaster::Scene.new( args.state.map,
                                                models,
                                                placements )


  # --- Player : ---
  args.state.player     = RayCaster::Player.new(  4,                              # speed
                                                  0.25,                           # dampening
                                                  1.0,                            # angular speed
                                                  textures[:basic_wall].width,    # texture size
                                                  0.5,                            # size (relative to texture size)
                                                  [ args.state.map.start_x,       # start position x
                                                    args.state.map.start_y ],     # start position y
                                                  90.0 )                          # start angle
  args.state.view_height_ratio  = 1

  # --- Renderer : ---
  args.state.renderer   = RayCaster::Renderer.new(  VIEWPORT_WIDTH,
                                                    VIEWPORT_HEIGHT,
                                                    FOCAL,
                                                    NEAR,
                                                    FAR,
                                                    textures[:basic_wall].width ) # texture size

  slices  = MAX_SPRITES.times.map do
              RayCaster::Slice.new  -SLICE_WIDTH,   # x
                                    0,              # y
                                    SLICE_WIDTH,    # width
                                    0,              # height
                                    TEXTURE_FILE,   # path
                                    MAX_LIGHT,      # red
                                    MAX_LIGHT,      # green
                                    MAX_LIGHT,      # blue
                                    0,              # source_x
                                    0,              # source_y
                                    0,              # source_w
                                    0               # source_h
            end
  args.state.slices = slices
  args.outputs.static_sprites << slices

  # --- Lighting : ---
  compute_lighting(args, 32, 128, 0)

  # --- Key Mapping : ---
  #args.state.mapping    = :qwerty
  args.state.mapping    = :azerty
  #KeyMap::set QWERTY_MAPPING
  KeyMap::set AZERTY_MAPPING

  # --- Miscellenaous : ---
  args.state.mode       = Debug::parse_debug_arg($gtk.argv)

  args.state.setup_done = true
end





# ---=== MAIN LOOP : ===---
def tick(args)

  # --- Setup : ---
  setup(args) unless args.state.setup_done


  # --- Update : ---
  
  # Game :
  args.state.player.update  args, args.state.map
  args.state.scene.update   args, args.state.player

  # Camera :
  args.state.renderer.focal     += 5    if args.inputs.keyboard.key_down.l
  args.state.renderer.focal     -= 5    if args.inputs.keyboard.key_down.k

  args.state.view_height_ratio  += 0.05 if args.inputs.keyboard.key_down.j
  args.state.view_height_ratio  -= 0.05 if args.inputs.keyboard.key_down.h

  args.state.mode = ( args.state.mode + 1 ) % 2 if args.inputs.keyboard.key_down.space

  # Key mapping selection :
  if args.inputs.keyboard.key_down.m then
    if args.state.mapping == :qwerty then
      puts 'switched to azerty'
      KeyMap::unset QWERTY_MAPPING
      args.state.mapping  = :azerty
      KeyMap::set   AZERTY_MAPPING

    elsif args.state.mapping == :azerty then
      puts 'switched to qwerty'
      KeyMap::unset AZERTY_MAPPING
      args.state.mapping  = :qwerty
      KeyMap::set   QWERTY_MAPPING

    end
  end


  # --- Render : ---
  columns = args.state.renderer.render  args.state.scene,
                                        args.state.player

  ## --- Draw : ---
  if args.state.mode == 0 || args.state.mode.nil? then
    args.outputs.solids  << [ [0,   0, 1279, 359, 40, 40, 40, 255],
                              [0, 360, 1279, 720, 50, 50, 50, 255] ]

    slice_count = 0
    columns.each.with_index do |column,index|
      column.each do |layer|
        #unless layer[:texture_path].nil? then
          slice = args.state.slices[slice_count]
          rectified_height  = layer[:height].to_i * 12
          lighting          = lighting_at args, layer[:distance].to_i

          slice.x         = SLICE_WIDTH * index
          slice.y         = ( args.grid.top - args.state.view_height_ratio * rectified_height ) / 2.0
          slice.w         = SLICE_WIDTH
          slice.h         = rectified_height
          slice.r         = lighting
          slice.g         = lighting
          slice.b         = lighting
          slice.source_x  = layer[:texture_offset_x]
          slice.source_y  = layer[:texture_offset_y]
          slice.source_w  = 1
          slice.source_h  = TEXTURE_SIZE

          slice.should_draw

          slice_count += 1
        #end
      end
    end

    slice_count.upto(MAX_SPRITES - 1) { |i| args.state.slices[i].should_not_draw }

  elsif args.state.mode == 1 then
    offset_world_space  = [20,100]
    Debug::render_map_top_down     args.state.scene.map,                      offset_world_space
    Debug::render_player_top_down  args.state.player,   args.state.renderer,  offset_world_space
    Debug::render_wall_hits        columns,                                   offset_world_space
    Debug::render_entities         args.state.scene,    args.state.player,    offset_world_space

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
  a = ( MAX_LIGHT.to_f - min_light ) / ( full_light_distance - min_light_distance )
  b = MAX_LIGHT - a * full_light_distance
  min_light_distance.times do |distance|
    if distance < full_light_distance then
      args.state.lighting[:gradient][distance]  = MAX_LIGHT
    else
      args.state.lighting[:gradient][distance]  = a * distance + b
    end
  end
end

def lighting_at(args,distance)
  distance < args.state.lighting[:min_light_distance] ? args.state.lighting[:gradient][distance] : args.state.lighting[:min_light]
end

