class ProtoProcessor::Tasks::CropTask < ProtoProcessor::Tasks::BaseTask
  def process
    new_name = './test_images/cropped.jpg'
    `convert -crop #{options[:top]}x#{options[:right]}+#{options[:bottom]}+#{options[:left]} #{input.path} #{new_name}`
    report! :path, new_name
  end
end