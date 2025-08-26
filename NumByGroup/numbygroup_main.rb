require 'sketchup.rb'
require 'extensions.rb'

module NumByGroup
  PLUGIN_ID = "NumByGroup".freeze

  module Core
    def self.number_groups
      model     = Sketchup.active_model
      entities  = model.active_entities
      selection = model.selection

      selected_groups = selection.grep(Sketchup::Group)
      if selected_groups.empty?
        UI.messagebox("Please select one or more groups.")
        return
      end

      # Ask user for settings
      prompts  = ["Starting Number:", "Prefix (optional):", "Text Height (mm):", "Extrusion (mm):"]
      defaults = [1, "Group", 100.mm, 10.mm]
      input    = UI.inputbox(prompts, defaults, "Numbering Groups with Extruded 3D Text")
      return if input.nil?

      starting_number = input[0].to_i
      prefix          = input[1]
      text_height     = input[2].to_l
      extrusion       = input[3].to_l

      model.start_operation("Number Groups", true)

      # Sort groups by lowest Z
      selected_groups.sort_by! { |group| group.bounds.corner(0).z }

      # Place 3D text on each group
      selected_groups.each_with_index do |group, index|
        number      = starting_number + index
        text_string = "#{prefix} #{number}"

        # Find top face
        top_face, highest_z = nil, -Float::INFINITY
        group.entities.grep(Sketchup::Face).each do |face|
          if face.bounds.center.z > highest_z
            highest_z = face.bounds.center.z
            top_face  = face
          end
        end
        next unless top_face

        text_position = top_face.bounds.center

        # Create extruded 3D text geometry
        text_group = entities.add_group
        text_group.entities.add_3d_text(
          text_string,
          TextAlignCenter,
          "Barlow Medium",  # changed font
          false,            # bold
          false,            # italic
          text_height,
          1,                # tolerance
          0,                # flat, extrusion handled separately
          true,             # filled
          extrusion         # extrusion depth
        )

        # Rotate upright (default 3D Text lies flat)
        center   = text_group.bounds.center
        rotation = Geom::Transformation.rotation(center, X_AXIS, 90.degrees)
        text_group.transform!(rotation)

        # Move text into position on group
        translation = Geom::Transformation.translation(text_position) * group.transformation
        text_group.transform!(translation)
      end

      model.commit_operation
    end

    # Add to menu
    unless file_loaded?(__FILE__)
      UI.menu("Plugins").add_item("Number Groups") {
        self.number_groups
      }

      # Toolbar button
      toolbar = UI::Toolbar.new "NumByGroup"

      cmd = UI::Command.new("Number Groups") {
        self.number_groups
      }
      cmd.small_icon = File.join(__dir__, "numbygroup_16.png")
      cmd.large_icon = File.join(__dir__, "numbygroup_24.png")
      cmd.tooltip    = "Number Groups with 3D Text"
      cmd.status_bar_text = "Creates extruded numbering text on top of selected groups."
      toolbar.add_item cmd
      toolbar.show

      file_loaded(__FILE__)
    end
  end
end
