class ProtoProcessor::Strategies::TestStrategy < ProtoProcessor::Strategies::BaseStrategy 
  
  # file = File.open('test.jpg')
  # s = ProtoProcessor::Strategies::TestStrategy.new(file, {})
  # s.run
  
  def process
    run_task CropTask, options['crop']
    
    run_task ResizeTask, options['sizes'] # will iterate sizes
    
    options['sizes'].each do |size_params|
      run_task [ResizeTask, CastorTask, CallbackTask], size_params
    end
    
    run_task ResizeTask, options['bogus'] # will not run
    
    run_task FailedTask, options # FAILED status
    
  end
  
end