class ProtoProcessor::Tasks::CropTask < ProtoProcessor::Tasks::BaseTask
  def process
    new_name = input.path#'./test_images/cropped.jpg'
    `convert -crop #{options[:width]}x#{options[:height]}+#{options[:top]}+#{options[:left]} #{input.path} #{new_name}`
    report! :path, new_name
  end
end