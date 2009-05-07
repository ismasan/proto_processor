$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'proto_processor'

class CropTask
  include ProtoProcessor::Task
  def process
    new_name = input.path#'./test_images/cropped.jpg'
    `convert -crop #{options[:width]}x#{options[:height]}+#{options[:top]}+#{options[:left]} #{input.path} #{new_name}`
    report! :path, new_name
  end
end

class FailedTask
  include ProtoProcessor::Task
  def process
    raise 'Oh no something went wrong!'
  end
end

class LogTask
  include ProtoProcessor::Task
  def process
    puts "--- Resized to #{report[:path]} with size #{options[:width]}x#{options[:height]}"
  end
end

class ResizeTask
  include ProtoProcessor::Task
  def process
    puts "Resizing #{input}"
    new_name = "./test_images/test_#{options[:width]}x#{options[:height]}.jpg"
    `convert -resize #{options[:width]}x#{options[:height]} #{input.path} #{new_name}`
    report! :path, new_name
  end
  
end

class TestStrategy
  include ProtoProcessor::Strategy
  
  # file = File.open('test.jpg')
  # s = TestStrategy.new(file, {})
  # s.run
  
  def initialize(input, options)
    @input, @options = input, options
  end
  
  def process
    
    with_input @input
    
    run_task CropTask, @options['crop']
    
    @options['sizes'].each do |size_params|
      run_task [ResizeTask, LogTask], size_params
    end
    
    run_task ResizeTask, @options['bogus'] # will not run
    
    run_task FailedTask, @options # FAILED status
    
  end
  
end

options = {
  "original" => 'test_images/test.jpg',
  "rotate" => 90,
  "crop" => {:width => 300, :height => 300, :top => 40, :left => 40},
  "sizes" => [
    {:width => 400, :height => 400},
    {:width => 300, :height => 300},
    {:width => 200, :height => 200}
  ]
}

File.open('test_images/tmp.jpg','w') do |f|
  f.write File.read(options.delete('original'))
end

file = File.open('test_images/tmp.jpg')

strategy = TestStrategy.new(file, options)

reports = strategy.run

puts reports.chain_outputs.inspect
# callback_to_merb reports

# update_files_to_castor reports

# {
#   :CropTask=>[
#     {:path=>"./test_images/cropped.jpg", :status=>"SUCCESS"}
#   ], 
#   :FailedTask=>[
#     {:status=>"FAILURE", :error=>{:name=>"RuntimeError", :message=>"Oh no something went wrong!"}}
#   ], 
#   :ResizeTask=>[
#     {:path=>"./test_images/test_400x400.jpg", :status=>"SUCCESS"}, {:path=>"./test_images/test_300x300.jpg", :status=>"SUCCESS"}, {:path=>"./test_images/test_200x200.jpg", :status=>"SUCCESS"}
#   ]
# }