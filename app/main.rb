# ---=== IMPORTS : ===---

# --- Raycasting Engine : ---
require 'lib/raycaster/debug.rb'
require 'lib/raycaster/extend_array.rb'
require 'lib/raycaster/trigo.rb'
require 'lib/raycaster/texture.rb'
require 'lib/raycaster/map.rb'
require 'lib/raycaster/cell.rb'
require 'lib/raycaster/entity.rb'
require 'lib/raycaster/scene.rb'
require 'lib/raycaster/lighting.rb'
require 'lib/raycaster/renderer.rb'
require 'lib/raycaster/slice.rb'
require 'lib/raycaster/keymap.rb'
require 'lib/raycaster/player.rb'

# --- Game Data : ---
require 'lib/raycaster/LDtk_bridge.rb'

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


  # --- Debugging : ---
  args.state.debug  = Debug::DebugOverlay.new
  args.outputs.static_sprites << args.state.debug


  # --- Miscellaneous : ---

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
    if args.state.debug.should_draw == false
      args.state.debug.should_draw = true
    else
      args.state.debug.should_draw = false
    end
  end

  if args.inputs.keyboard.key_down.p
    args.outputs.screenshots << { x: 0, y: 0, w: 1280, h: 720,
                                  path: 'debug.png',
                                  r: 255, g: 255, b: 255, a: 0
                                }
  end


  # --- Render : ---
  args.state.game.render(args)
  args.state.debug.render(args.state.game)
end

