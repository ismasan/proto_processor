module ProtoProcessor
  class TaskRunner
    
    attr_reader :report
    
    def initialize(report)
      @report = report
    end
    
    def run_chain(run_key, task_classes, initial_input, options, initial_report, &block)
      tasks = []
      output = task_classes.inject([initial_input, options, initial_report]) do |args, task_class|
        task = task_class.new(args)
        tasks << task
        task.run
      end
      block.call(tasks, output.first, output.last) if block_given?
      @report.report(run_key, tasks, output)
      output
    end
    
    
  end
end