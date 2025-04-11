module RayCaster
  module Lighting
    def self.compute(full_light_distance,min_light_distance,max_light,min_light)
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
          @@lighting[:gradient][distance] = a * distance + b
        end
      end
    end
    
    def self.at(distance)
      distance < @@lighting[:min_light_distance] ? @@lighting[:gradient][distance] : @@lighting[:min_light]
    end
  end
end
