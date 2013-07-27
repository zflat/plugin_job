require 'plugin_job/updater'

module PluginJob
  class PluginCollection
    attr_reader :map, :scope

    #
    # @param Hash map where each key is a category 
    # and each value is an array representing the list
    # of plugins in the category
    def initialize(map, scope)
      @map = map
      @scope = scope

      add_cmd(update_cmd)
    end

    def command_list
      map.values.flatten.map{ |c| c.to_s } + [update_cmd]
    end

    def categories
      map.keys
    end

    def [](command)
      if command == ""
        PluginJob::Worker
      else
        @scope.const_get(command.to_sym)
      end
    end

    def has_command?(command)
      command_list.include?(command.to_s)
    end

    private

    def update_cmd
      "UpdatePlugins"
    end

    def add_cmd(cmd_str)
      @scope.instance_eval do
        const_set(cmd_str, Updater::UpdateJob)
      end
    end
    
  end # class
end # module
