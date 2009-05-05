module ProtoProcessor
  ROOT = File.dirname(__FILE__)
  $: << File.join(ROOT, 'proto_processor')
  module Strategies
    autoload :BaseStrategy, 'strategies/base_strategy'
    autoload :TestStrategy, 'strategies/test_strategy'
    
    def self.create(type, input, options = {})
      const_get("#{type}Strategy".to_sym).new(input, options)
    end
  end
  
  module Tasks
    autoload :BaseTask, 'tasks/base_task'
    autoload :CropTask, 'tasks/crop_task'
    autoload :FailedTask, 'tasks/failed_task'
    autoload :ResizeTask, 'tasks/resize_task'
  end
end