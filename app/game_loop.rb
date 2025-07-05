module Game
  class Loop
    attr_reader :levels, :map, :scene, :player, :renderer

    def initialize(ldtk_file)
      # --- Level Data : ---
      ldtk_data = $gtk.args.gtk.parse_json_file(ldtk_file)
      @levels   = LDtk.parse(ldtk_data, Game::Data::TEXTURE_SIZE)

      # --- Map : ---
      @map  = RayCaster::Map.new( @levels.first[:cells],
                                  Game::Data::CELLS,
                                  Game::Data::TEXTURES,
                                  Game::Data::TEXTURE_FILE )

      # --- Scene : ---
      @scene  = RayCaster::Scene.new( @map,
                                      @levels.first[:entities],
                                      Game::Data::ENTITIES,
                                      Game::Data::TEXTURES,
                                      Game::Data::TEXTURE_FILE )

      # --- Player : ---
      @player = RayCaster::Player.new(  4,                            # speed
                                        0.25,                         # dampening
                                        1.0,                          # angular speed
                                        Game::Data::TEXTURE_SIZE,     # texture size
                                        0.5,                          # size (relative to texture size)
                                        [ @levels.first[:start][0],
                                          @levels.first[:start][1] ],
                                        90.0 )                        # start angle

      # --- Lighting : ---
      RayCaster::Lighting::compute( FULL_LIGHT_DISTANCE,
                                    MIN_LIGHT_DISTANCE,
                                    MAX_LIGHT,
                                    MIN_LIGHT,
                                    VIEWPORT_HEIGHT,
                                    FOCAL,
                                    @levels.first[:top_color],
                                    @levels.first[:bottom_color] )

      # --- Renderer : ---
      @renderer = RayCaster::Renderer.new(  VIEWPORT_WIDTH,
                                            VIEWPORT_HEIGHT,
                                            FOCAL,
                                            NEAR,
                                            FAR,
                                            Game::Data::TEXTURE_FILE,
                                            Game::Data::TEXTURE_SIZE )  # texture size
    end

    def tick(args)
      # Game :
      @player.update  args, @map
      @scene.update   args, @player

      # Camera :
      #@renderer.focal     += 5    if args.inputs.keyboard.key_down.l
      #@renderer.focal     -= 5    if args.inputs.keyboard.key_down.k
    end

    def render(args)
      #args.outputs.solids  << [ [0,   0, 1279, 359, 40, 40, 40, 255],
      #                          [0, 360, 1279, 720, 50, 50, 50, 255] ]

      @renderer.render  @scene, @player
    end
  end
end
