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
require 'app/game_loop.rb'





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
  # --- Game : --- 
  args.state.game = Game::Loop.new LDTK_FILE

  # --- Key Mapping : ---
  #args.state.mapping    = :qwerty
  args.state.mapping    = :azerty
  #KeyMap::set QWERTY_MAPPING
  KeyMap::set AZERTY_MAPPING

  # --- Miscellenaous : ---
  #args.state.mode       = Debug::parse_debug_arg($gtk.argv)
  args.state.debug  = false

  args.state.setup_done = true
end





# ---=== MAIN LOOP : ===---
def tick(args)

  # --- Setup : ---
  setup(args) unless args.state.setup_done


  # --- Update : ---
  
  # Game :
  args.state.game.tick(args)

  # Key mapping selection :
  if args.inputs.keyboard.key_down.m then
    if args.state.mapping == :qwerty then
      KeyMap::unset QWERTY_MAPPING
      args.state.mapping  = :azerty
      KeyMap::set   AZERTY_MAPPING

    elsif args.state.mapping == :azerty then
      KeyMap::unset AZERTY_MAPPING
      args.state.mapping  = :qwerty
      KeyMap::set   QWERTY_MAPPING

    end
  end

  # Debug :
  if args.inputs.keyboard.key_down.tab
    args.state.debug = !args.state.debug
  end


  # --- Render : ---
  args.state.game.render(args)
  #args.state.renderer.render  args.state.scene, args.state.player

  ## --- Draw : ---
  #if args.state.mode == 0 || args.state.mode.nil? then
  #  args.outputs.solids  << [ [0,   0, 1279, 359, 40, 40, 40, 255],
  #                            [0, 360, 1279, 720, 50, 50, 50, 255] ]


  #elsif args.state.mode == 1 then
  if args.state.debug
    offset_world_space  = [20,100]
    Debug::render_game_top_down  args.state.game, offset_world_space

    #Debug::render_map_top_down     args.state.scene.map,                      offset_world_space
    #Debug::render_player_top_down  args.state.player,   args.state.renderer,  offset_world_space
    #Debug::render_wall_hits        args.state.renderer.columns,               offset_world_space
    #Debug::render_entities         args.state.scene,    args.state.player,    offset_world_space

  end
end

