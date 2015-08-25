require 'volt/server/html_parser/view_parser'
require 'volt/server/component_templates'
require 'volt/server/rack/asset_files'

# Takes in the name and all component paths and has a .code
# method that returns all of the ruby setup code for the component.
module Volt
  class ComponentCode
    def initialize(volt_app, component_name, component_paths, client = true)
      @volt_app        = volt_app
      @component_name  = component_name
      @component_paths = component_paths
      @client          = client
    end

    # The client argument is for if this code is being generated for the client
    def code
      # Start with config code
      code = @client ? generate_config_code : ''

      asset_files = AssetFiles.from_cache(@volt_app.app_url, @component_name, @component_paths)
      asset_files.component_paths.each do |component_path, component_name|
        code << ComponentTemplates.new(component_path, component_name, @client).code
        code << "\n\n"
      end

      code
    end

    def generate_config_code
      # Setup Volt.config on the client
      "\nVolt.setup_client_config(#{Volt.config.public.to_h.inspect})\n"
    end
  end
end
