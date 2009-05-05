$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'proto_processor'

options = {
  "original" => 'test_images/test.jpg',
  "type" => "Test",
  "rotate" => 90,
  "crop" => {:left => 100, :right => 20, :top => 20, :bottom => 20},
  "sizes" => [
    {:width => 400, :height => 400},
    {:width => 300, :height => 300},
    {:width => 200, :height => 200}
  ]
}

file = File.open(options.delete('original'))

strategy = ProtoProcessor::Strategies.create(options.delete('type'), file, options)

puts strategy.run.inspect
