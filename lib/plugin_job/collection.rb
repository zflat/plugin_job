module PluginJob
  class Collection
    attr_reader :map

    #
    # @param Hash map where each key is a category 
    # and each value is an array representing the list
    # of plugins in the category
    def initialize(map, scope=Object)
      @map = map
      @scope = scope
    end

    def command_list
      map.values.flatten.map{ |c| c.to_s }
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
    
  end
end
