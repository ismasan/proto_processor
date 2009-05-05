class ProtoProcessor::Strategies::TestStrategy < ProtoProcessor::Strategies::BaseStrategy 
  
  # file = File.open('test.jpg')
  # s = ProtoProcessor::Strategies::TestStrategy.new(file, {})
  # s.run
  
  def process
    run_task CropTask, options['crop']
    
    run_task ResizeTask, options['sizes'] # will iterate sizes
    
    run_task ResizeTask, options['bogus'] # will not run
    
    run_task FailedTask, options # FAILED status
    
  end
  
end