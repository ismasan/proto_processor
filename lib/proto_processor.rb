module ProtoProcessor
  ROOT = File.dirname(__FILE__)
  $: << File.join(ROOT, 'proto_processor')
  
  def self.autoload_all(mod)
    Dir.glob(File.join(ROOT,'proto_processor',mod.name.split('::').last.downcase+'/*.rb')).each do |path|
      klass = File.basename(path).sub('.rb','').split('_').map{|e|e.capitalize}.join.to_sym
      mod.autoload klass, path
    end
  end
  
  module Strategies
    ProtoProcessor.autoload_all(self)

    def self.create(type, input, options = {})
      const_get("#{type}Strategy".to_sym).new(input, options)
    end
  end
  
  module Tasks
    ProtoProcessor.autoload_all(self)
  end
end