module RayCaster
  module Lighting
    def self.compute(full_light_distance,min_light_distance,max_light,min_light,viewport_height,focal,top_color,bottom_color)
      # Bounds :
      @@lighting                       = {}
      @@lighting[:full_light_distance] = full_light_distance
      @@lighting[:min_light_distance]  = min_light_distance
      @@lighting[:max_light]           = max_light
      @@lighting[:min_light]           = min_light
      
      # Gradient :
      @@lighting[:gradient] = []
      a = ( @@lighting[:max_light].to_f - min_light ) / ( full_light_distance - min_light_distance )
      b = @@lighting[:max_light] - a * full_light_distance
      min_light_distance.times do |distance|
        if distance < full_light_distance then
          @@lighting[:gradient][distance] = @@lighting[:max_light]
        else
          @@lighting[:gradient][distance] = ( a * distance + b ).to_i
        end
      end

      $gtk.args.render_target(:background_gradient).width   = 1
      $gtk.args.render_target(:background_gradient).height  = 8 * viewport_height
      (viewport_height / 2).to_i.times do |h|
        #distance  = ( viewport_height / 2.0 ) * focal / ( viewport_height / 2 - h ).to_f
        distance  = ( viewport_height / 2.0 ) * focal / ( viewport_height / 1.5 - h ).to_f
        light     = distance < min_light_distance ? @@lighting[:gradient][distance] : min_light
        $gtk.args.render_target(:background_gradient).sprites  << { x: 0,
                                                                    y: 8 * h,
                                                                    w: 1,
                                                                    h: 8,
                                                                    path:  :pixel,
                                                                    r:     ( bottom_color[0] / 255.0 ) * light,
                                                                    g:     ( bottom_color[1] / 255.0 ) * light,
                                                                    b:     ( bottom_color[2] / 255.0 ) * light,
                                                                    a:     255 }
        $gtk.args.render_target(:background_gradient).sprites  << { x: 0,
                                                                    y: 8 * ( viewport_height - h ),
                                                                    w: 1,
                                                                    h: 8,
                                                                    path:  :pixel,
                                                                    r:     ( top_color[0] / 255.0 ) * light,
                                                                    g:     ( top_color[1] / 255.0 ) * light,
                                                                    b:     ( top_color[2] / 255.0 ) * light,
                                                                    a:     255 }
      end
    end
    
    def self.at(distance)
      distance < @@lighting[:min_light_distance] ? @@lighting[:gradient][distance] : @@lighting[:min_light]
    end
  end
end
