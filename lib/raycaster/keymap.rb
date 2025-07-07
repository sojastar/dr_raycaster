module KeyMap
 def self.set(mapping)
   mapping.each_pair do |command,key|
    GTK::KeyboardKeys.send :alias_method, command, key
   end
 end

 def self.unset(mapping)
   mapping.each_pair do |command,key|
    GTK::KeyboardKeys.send :undef_method, command
   end
 end
end
