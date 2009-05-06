module ProtoProcessor
  module Tasks
    class Runner
      
      class << self
        
        def run_chain(task_classes, initial_input, options, initial_report, &block)
          tasks = []
          output = task_classes.inject([initial_input, options, initial_report]) do |args, task_class|
            task = task_class.new(args)
            tasks << task
            task.run
          end
          block.call(tasks, output.first, output.last) if block_given?
          output
        end
        
      end
      
      
    end
  end
end