# ---=== IMPORTS : ===---

# --- Raycasting Engine : ---
require 'lib/debug.rb'
require 'lib/extend_array.rb'
require 'lib/trigo.rb'
require 'lib/texture.rb'
require 'lib/map.rb'
require 'lib/cell.rb'
require 'lib/entity.rb'
require 'lib/scene.rb'
require 'lib/lighting.rb'
require 'lib/renderer.rb'
require 'lib/slice.rb'
require 'lib/keymap.rb'
require 'lib/player.rb'

# --- Game Data : ---
require 'lib/LDtk_bridge.rb'

require 'data/texture_data.rb'
require 'data/cell_data.rb'
require 'data/entity_data.rb'

# --- Game Logic : --- 





# ---=== CONSTANTS : ===---

# --- Rendering : ---
VIEWPORT_WIDTH  = 160
VIEWPORT_HEIGHT = 90
FOCAL           = 80
NEAR            = 16
FAR             = 1500

MAX_SPRITES = 500
SLICE_WIDTH = $gtk.args.grid.right / VIEWPORT_WIDTH

MAX_LIGHT           = (1 << 8) - 1
MIN_LIGHT           = 0
FULL_LIGHT_DISTANCE = 32
MIN_LIGHT_DISTANCE  = 128

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

# --- Game Data : ---
LDTK_FILE = 'data/maps/map.ldtk'





# ---=== SETUP : ===---
def setup(args)
  
  # --- Textures : ---
  textures  = Game::TEXTURES.to_a
                            .map { |name,data|
                              [ name,
                                RayCaster::Texture.new( Game::TEXTURE_FILE,
                                                        data[:width],
                                                        data[:height],
                                                        data[:frames],
                                                        data[:mode],
                                                        data[:speed] ) ]
                            }
                            .to_h

  # --- Cells : ---
  cells  = Game::CELLS.to_a
                      .map { |cell_data|
                        name    = cell_data[0]
                        texture = textures[cell_data[1][:texture]]
                        type    = cell_data[1][:type]

                        case type
                        when :empty
                          [ name, RayCaster::Cell.new(nil, type) ]
                        when :door
                          [ name, RayCaster::Door.new(texture) ]
                        else
                          [ name, RayCaster::Cell.new(texture, type) ]
                        end
                      }
                      .to_h

  # --- Map : ---
  ldtk_data = args.gtk.parse_json_file(LDTK_FILE)
  levels    = LDtk.parse(ldtk_data, Game::TEXTURE_SIZE)

  args.state.map        = RayCaster::Map.new( levels.first[:cells],
                                              cells,
                                              Game::TEXTURE_SIZE,
                                              levels.first[:start][0],
                                              levels.first[:start][1] )

  # --- Entities : ---
  models  = Game::ENTITIES.to_a
                          .map { |entity_data|
                            type          = entity_data[0]
                            texture       = textures[entity_data[1][:texture]]
                            colide        = entity_data[1][:colide]
                            other_params  = entity_data[1][:other_params]

                            [ type,
                              { texture:      texture,
                                colide:       colide,
                                other_params: other_params } ]
                          }
                          .to_h

  # --- Scene : ---
  args.state.scene      = RayCaster::Scene.new( args.state.map,
                                                models,
                                                levels.first[:entities] )


  # --- Player : ---
  args.state.player     = RayCaster::Player.new(  4,                              # speed
                                                  0.25,                           # dampening
                                                  1.0,                            # angular speed
                                                  textures[:basic_wall].width,    # texture size
                                                  0.5,                            # size (relative to texture size)
                                                  [ levels.first[:start][0],
                                                    levels.first[:start][1] ],
                                                  90.0 )                          # start angle

  # --- Lighting : ---
  RayCaster::Lighting::compute( FULL_LIGHT_DISTANCE,
                                MIN_LIGHT_DISTANCE,
                                MAX_LIGHT,
                                MIN_LIGHT )

  # --- Renderer : ---
  args.state.renderer = RayCaster::Renderer.new(  VIEWPORT_WIDTH,
                                                  VIEWPORT_HEIGHT,
                                                  FOCAL,
                                                  NEAR,
                                                  FAR,
                                                  Game::TEXTURE_FILE,
                                                  textures[:basic_wall].width ) # texture size

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
  args.state.renderer.render  args.state.scene, args.state.player

  ## --- Draw : ---
  if args.state.mode == 0 || args.state.mode.nil? then
    args.outputs.solids  << [ [0,   0, 1279, 359, 40, 40, 40, 255],
                              [0, 360, 1279, 720, 50, 50, 50, 255] ]


  elsif args.state.mode == 1 then
    offset_world_space  = [20,100]
    Debug::render_map_top_down     args.state.scene.map,                      offset_world_space
    Debug::render_player_top_down  args.state.player,   args.state.renderer,  offset_world_space
    Debug::render_wall_hits        args.state.renderer.columns,               offset_world_space
    Debug::render_entities         args.state.scene,    args.state.player,    offset_world_space

  end
end

