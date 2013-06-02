require 'plugin_job/updater'

module PluginJob
  class Collection
    attr_reader :map, :scope

    #
    # @param Hash map where each key is a category 
    # and each value is an array representing the list
    # of plugins in the category
    def initialize(map, scope)
      @map = map
      @scope = scope

      cmd_set = update_cmd
      @scope.instance_eval do
        const_set(cmd_set, Updater::UpdateJob)
      end
    end

    def command_list
      map.values.flatten.map{ |c| c.to_s } + [update_cmd]
    end

    def categories
      map.keys
    end

    def [](command)
      @scope.const_get(command.to_sym)
    end

    def has_command?(command)
      command_list.include?(command.to_s)
    end

    private

    def update_cmd
      "UpdatePlugins"
    end
    
  end
end
