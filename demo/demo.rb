$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'proto_processor'

require 'tempfile'
class TempfileExtension < Tempfile
  def make_tmpname(basename, n)
    # force tempfile to use basename's extension if provided
    ext = File::extname(basename)
    # force hyphens instead of periods in name
    sprintf('%s%d-%d%s', File::basename(basename, ext), $$, n, ext)
  end
end

class CropTask
  include ProtoProcessor::Task
  def process
    new_name = input.path
    `convert -crop #{options[:width]}x#{options[:height]}+#{options[:top]}+#{options[:left]} #{input.path} #{new_name}`
    report! :tmp_path, new_name
  end
end

class RotateTask
  include ProtoProcessor::Task
  def process
    new_name = input.path
    `convert -rotate 90 #{input.path} #{new_name}`
    report! :path, new_name
  end
end

class FailedTask
  include ProtoProcessor::Task
  def process
    raise 'Oh no something went wrong!'
  end
end

class CleanupTask
  include ProtoProcessor::Task
  def process
    File.delete report[:tmp_path]
  end
end

class LogTask
  include ProtoProcessor::Task
  def process
    puts "------ Resized #{input.path}"
    File.open('./test_images/'+UUID.new.generate+'.png','w') do |f|
      f.write File.read(report[:tmp_path])
    end
    #puts "--- Resized to #{report[:path]} with size #{options[:width]}x#{options[:height]}"
  end
end

require 'rubygems'
require 'mini_magick'
require 'uuid'
class ResizeTask
  include ProtoProcessor::Task
  def process
    background = options[:background]
    colors     = options[:colors]
    depth      = options[:depth]
    height     = options[:height]
    mime_type  = options[:mime_type]
    padding    = options[:padding]
    width      = options[:width]
    encoding   = options[:encoding] || 'jpeg'
    
    puts "Resizing #{input}"
    # new_name = "./test_images/test_#{options[:width]}x#{options[:height]}.#{encoding}"
    
    image = MiniMagick::Image.from_file(input.path)
    image.combine_options do |c|
      c.colors colors if colors
      c.depth depth if depth
      c.background background if background
      c.resize "#{options[:width]}x#{options[:height]}" if resizable?
      if padding
        c.background '#00000000' unless background
        c.extent "#{width}x#{height}"
        c.gravity 'Center'
      end
    end
    tmp = [Dir::tmpdir+'/'+UUID.new.generate,encoding].join('.')
    image.write(tmp)
    report! :tmp_path, tmp
  end
  
  protected
  
  def resizable?
    options.has_key?(:width) && options.has_key?(:height)
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
    
    run_task RotateTask, {}
    
    @options['sizes'].each do |size_params|
      run_task [ResizeTask, LogTask, CleanupTask], size_params
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
    {:width => 400, :height => 400, :colors => 8},
    {:width => 1000, :height => 200, :background => '#ccff0033', :padding => true, :encoding => 'png'},
    {:width => 200, :height => 200, :depth => 2},
    {:width => 1100, :height => 200, :background => '#00ff0033', :padding => true}
  ]
}

file = TempfileExtension.new('original.png')
file.write File.read(options.delete('original'))
file.close

strategy = TestStrategy.new(file, options)

reports = strategy.run

puts reports.chain_outputs.inspect