=begin

Copyright 2024, Author 
All Rights Reserved

License: AuthorsLicenseStatement 
Author: MSP
Organization:  
Name: NumByGroup
Version: 1.0.0
SU Version: SU2017 Up 
Date: 15 Oct 2024
Description: Numbering tool for any group/component with custom text. 
Usage:  
History:
    1.0.0 2024-10-14 First Developed
    
=end

require 'sketchup.rb'
require 'extensions.rb'

# Wrap in your own module. Start its name with a capital letter

module MY_Extensions

  module MY_ThisExtension

    # Load extension
    my_extension_loader = SketchupExtension.new( 'NumByGroup' , 'NumByGroup/num_by_group.rb' )
    my_extension_loader.copyright = 'Copyright 2024 by MSP' 
    my_extension_loader.creator = 'MSP' 
    my_extension_loader.version = '1.0.0' 
    my_extension_loader.description = 'Description of this extension.'
    Sketchup.register_extension( my_extension_loader, true )

  end  # module MY_ThisExtension
  
end  # module MY_Extensions
