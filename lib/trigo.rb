module RayCaster
  module Trigo
    def self.deg_to_rad(angle)
      Math::PI * angle / 180.0
    end

    def self.rad_to_deg(angle)
      180.0 * angle / Math::PI
    end

    def self.magnitude(point1,point2)
      Math::sqrt((point1[0] - point2[0]) ** 2 + (point1[1] - point2[1]) ** 2)
    end

    def self.unit_vector_for(angle)
      [ Math::cos(angle), Math::sin(angle) ]
    end

    def self.normal(vector)
      [ -vector[1], vector[0] ]
    end
  end
end
