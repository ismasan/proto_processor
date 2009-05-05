class ResizeTask < ProtoProcessor::Tasks::BaseTask
  
  def process
    new_name = "./test_images/test_#{options[:width]}x#{options[:height]}.jpg"
    `convert -resize #{options[:width]}x#{options[:height]} #{input.path} #{new_name}`
    report! :path, new_name
  end
  
end