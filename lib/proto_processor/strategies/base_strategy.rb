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
  def run_task(task_class, options = nil)
    return false if options.nil?
    if options.kind_of?(Array)
      options.each {|o| run_single_task(task_class, o)}
    else
      run_single_task(task_class, options)
    end
  end
  
  protected
  
  def run_single_task(task_class, options)
    @input, temp_options, @report = task_class.new([@input, options, @report]).run
  end
  
end