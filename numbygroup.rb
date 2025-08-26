require 'sketchup.rb'
require 'extensions.rb'

module NumByGroup
  unless file_loaded?(__FILE__)
    extension = SketchupExtension.new('NumByGroup', 'NumByGroup/numbygroup_main')
    extension.description = 'Number groups with extruded 3D text.'
    extension.version     = '2.0.0b'
    extension.creator     = 'MSP'
    Sketchup.register_extension(extension, true)
    file_loaded(__FILE__)
  end
end
