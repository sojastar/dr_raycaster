module Debug
  def self.draw_cross(position,size,color)
    $gtk.args.outputs.lines <<  [ [ position[0] - size,     position[1] - size,
                                    position[0] + size + 2, position[1] + size + 2 ] + color,
                                  [ position[0] - size,     position[1] + size + 2,
                                    position[0] + size + 2, position[1] - size     ] + color  ]
  end
end 
