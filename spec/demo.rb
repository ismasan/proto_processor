$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'proto_processor'

options = {
  "original" => 'test_images/test.jpg',
  "type" => "Test",
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

strategy = ProtoProcessor::Strategies.create(options.delete('type'), file, options)

puts strategy.run.inspect

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