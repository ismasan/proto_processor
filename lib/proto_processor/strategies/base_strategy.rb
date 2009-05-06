class ProtoProcessor::Strategies::BaseStrategy
  include ProtoProcessor::Tasks
  
  attr_reader :report, :input, :options
  
  def initialize(input, options = {})
    @input, @options = input, options
    @report = {}
  end
  
  def run
    process
    yield @report if block_given?
    @report
  end
  
  def process
    raise NotImplementedError, "You must implement #process in your strategies"
  end
  
  # === Run a task and update input and report (but don't update options)
  # If passed and array of options, run task for each option hash
  #
  def run_task(task_class, options = nil, &block)
    return false if options.nil?
    run_single_task_or_chain(task_class, options, &block)
  end
  
  protected
  
  def run_single_task_or_chain(task_class, options, &block)
    @input, temp_options, @report = Runner.run_chain([*task_class],@input, options, @report, &block)
  end
  
end