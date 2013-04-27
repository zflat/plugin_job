module PluginJob
  class Collection
    attr_reader :map

    #
    # @param Hash map where each key is a category 
    # and each value is an array representing the list
    # of plugins in the category
    def initialize(map)
      @map = map
    end

    def command_list
      map.values.flatten
    end

    def categories
      map.keys
    end

    def has_command?(command)
      command_list.include?(command)
    end
    
  end
end
