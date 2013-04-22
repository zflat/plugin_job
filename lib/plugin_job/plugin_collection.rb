module PluginJob

  class PluginCollection
    
    def initialize
      @collection = []
    end

    def [](arg)
      @collection[arg]
    end

    def command_list
      @collection.keys
    end

    def self.plugin_class(file_name)
      # Adapted from the Rails camelize function
      string = file_name.to_s.sub.sub(/^[a-z\d]*/){ $&.capitalize }
      string.gsub(/(?:_|(\/))([a-z\d]*)/) { "#{$1}#{$2.capitalize}" }.gsub('/', '::')
    end

    def self.load_directory(dir_path)
      collection = self.class.new
      return collection
    end

  end
  
end
