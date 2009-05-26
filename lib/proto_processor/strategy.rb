module ProtoProcessor::Strategy
  
  def report
    @report ||= ProtoProcessor::Report.new
  end
  
  def runner
    @task_runner ||= ProtoProcessor::TaskRunner.new(report)
  end
  
  def run
    begin
      ProtoProcessor.logger.info "Running strategy #{self.class.name}"
      process
    rescue StandardError => e
      report.fail!(e)
      ProtoProcessor.logger.error e.class.name
      ProtoProcessor.logger.debug e.message + "\n" + e.backtrace.join("\n")
    end
    yield report if block_given?
    report
  end
  
  def process
    raise NotImplementedError, "You must implement #process in your strategies"
  end
  
  def with_input(input)
    @current_input = input#.dup # dup so we don't overwrite passed input later on
  end
  
  def current_input
    @current_input ||= ''
  end
  
  # === Run a task and update input and report (but don't update options)
  # If passed and array of options, run task for each option hash
  #
  def run_task(task_class, options = nil, &block)
    return false if options.nil?
    run_task_chain([*task_class], options, &block)
  end
  
  protected
  
  def run_task_chain(task_classes, options, &block)
    chain_key = task_classes.first.name.split('::').last.to_sym
    @current_input, temp_options, task_report = runner.run_chain(chain_key, task_classes,current_input, options, {}, &block)
  end
  
end