require 'sketchup.rb'


# Define the module for the custom tool
module CustomTool
  # Method to create the toolbar
  def self.create_toolbar
    # Create a new toolbar
    toolbar = UI::Toolbar.new("Num By Group")

    # Command for numbering groups
    command_number = UI::Command.new("Number Groups") {
      # Your numbering groups script
      model = Sketchup.active_model
      entities = model.active_entities
      selection = model.selection

      # Check if there are any selected groups
      selected_groups = selection.grep(Sketchup::Group)

      if selected_groups.empty?
        UI.messagebox("Please select at least one group.")
        return
      end

      # Step 1: Ask the user for starting number and prefix
      prompts = ["Starting Number:", "Prefix (optional):", "Text Height (mm):"]
      defaults = [1, "Group", 100.mm]
      input = UI.inputbox(prompts, defaults, "Numbering Groups with 3D Text (Vertical on Surface)")

      # Handle user cancellation
      return if input.nil?

      starting_number = input[0].to_i
      prefix = input[1]
      text_height = input[2].to_l

      # Step 2: Sort the selected groups by their lowest Z point (bottom to top)
      selected_groups.sort_by! { |group| group.bounds.corner(0).z }

      # Step 3: Iterate through the sorted groups and add 3D text labels
      selected_groups.each_with_index do |group, index|
        number = starting_number + index
        text_string = "#{prefix} #{number}"

        # Get the center of the group's top face for positioning the 3D text
        top_face = nil
        highest_z = -Float::INFINITY

        group.entities.each do |entity|
          if entity.is_a?(Sketchup::Face)
            face_center_z = entity.bounds.center.z
            if face_center_z > highest_z
              highest_z = face_center_z
              top_face = entity
            end
          end
        end

        # If no face is found, skip this group
        next unless top_face

        # Get the position for the text (center of the top face)
        text_position = top_face.bounds.center

        # Step 4: Create a 3D text group in the model
        text_group = entities.add_group # Create a new group for the text in the model's entities
        text_group.entities.add_3d_text(
          text_string,   # Text string
          TextAlignCenter, # Center-align the text
          "Arial",       # Font
          false,         # Bold
          false,         # Italic
          text_height,   # Text height
          1,             # Tolerance
          0,             # Extrusion (flat text)
          true           # Filled
        )

        # Step 5: Set the text's position based on the original group's position
        transformation = Geom::Transformation.translation(text_position) * group.transformation
        text_group.transform!(transformation)
      end
    }

    command_number.tooltip = "Number the selected groups with 3D text."
    command_number.status_bar_text = "Number the selected groups with 3D text."
    command_number.menu_text = "Number Groups"
    command_number.large_icon = File.join(__dir__, 'icons', 'large_icon_text.png')
    command_number.small_icon = File.join(__dir__, 'icons', 'small_icon_text.png')

    toolbar.add_item(command_number)

    # Command for rotating groups
    command_rotate = UI::Command.new("Rotate Groups") {
      # Your rotate groups script
      model = Sketchup.active_model
      selection = model.selection

      # Check if the user has selected any groups or components
      if selection.empty?
        UI.messagebox("Please select at least one group or component.")
        return
      end

      # Define the rotation angle (90 degrees, converting to radians)
      angle = 90.degrees

      # Create a transformation for rotating around the X-axis
      x_axis = Geom::Vector3d.new(1, 0, 0)

      # Loop through each selected entity
      selection.each do |selected_entity|
        # Ensure the selected entity is a group or component
        if selected_entity.is_a?(Sketchup::Group) || selected_entity.is_a?(Sketchup::ComponentInstance)
          # Get the bounds of the selected entity to determine its position
          bounds = selected_entity.bounds

          # Get the center of the entity for the rotation point
          center = bounds.center

          # Create the rotation transformation
          rotation_transformation = Geom::Transformation.rotation(center, x_axis, angle)

          # Apply the rotation transformation to the selected entity
          selected_entity.transform!(rotation_transformation)
        else
          UI.messagebox("One of the selected items is not a group or component.")
        end
      end
    }

    command_rotate.tooltip = "Rotate the selected groups or components upright."
    command_rotate.status_bar_text = "Rotate the selected groups or components upright."
    command_rotate.menu_text = "Rotate Groups"
    command_rotate.large_icon = File.join(__dir__, 'icons', 'large_icon_rotate.png')
    command_rotate.small_icon = File.join(__dir__, 'icons', 'small_icon_rotate.png')

    toolbar.add_item(command_rotate)

    # Show the toolbar
    toolbar.show
  end
end

# Call the create_toolbar method when the plugin is loaded
CustomTool.create_toolbar
