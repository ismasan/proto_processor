## proto_processor

A couple of modules to ease the creation of background processors or any kind of delegated task or tasks for which you want flow control and error reporting.

## Examples

### Strategies

You start by defining a *strategy*. A strategy defines the sequence of tasks your program will carry out.

    require 'rubygems'
    require 'proto_processor'

    class ImageStrategy
      include ProtoProcessor::Strategy
     
      # :process runs you strategy
      #
      def process
        
        options = {:width => 300, :height => 200}

        # set the initial input
        with_input File.open('some_file.jpg')
  
        # Run the file though a resize task
        run_task ResizeTask, options

        # store the modified file
        run_task StoreFileTask
      end
       
    end

Run it:

    strategy = ImageStrategy.new
    report = strategy.run
    puts report.inspect

The Strategy module just adds a few methods to run your tasks in a declarative manner. The :process method sets an input to be used as a starting point with *with_input*, and declares the sequence of tasks to be run on that input with *run_task*, which takes the task class and an options hash as arguments.

Strategy#run captures the output of tasks and gives you a Report object, with information about the tasks run, their output and possible errors.

Apart from the *process* method, Strategies are normal Ruby classes so you can go ahead and add whatever functionality you want to them, including, for example, an *initialize* method, or a factory.

### Tasks

Tasks do the real work. They also implement a *process* method where you can put you image resizing, file storing, email sending or whatever code you want.

    require 'mini_magick'
    class ResizeTask
      include ProtoProcessor::Task
      
      expects_options_with :width
      expects_options_with :height

      def process
        image = MiniMagick::Image.new(input.path)
        image.resize "#{options[:width]}x#{options[:height]}"
      end
    end

That's pretty much it. Any exceptions raised within *process* will be captured, logged and stored in the task report which will be available as part of the Strategy-wide Report object.

Every task has an *options* hash available.

### Validating task options

The previous example shows a simple way of checking that a task was passed required parameters as part of the options hash.

   expects_options_with :width

If parameters declared in this way are not present in the options, a ProtoProcessor::MissingParametersError exception will be raised and logged in the task report (your task won't blow up though). The process method won't be run.

You can also raise manually in the process method.

    def process
      raise ArgumentError, ":width option must be > 0" if options[:width] < 1
    end

Tasks also have *before_process* and *after_process* callbacks that will run if defined. You can guess what they do :)

Lastly, you can define your own *validate* method which will be run before processing. If validate returns false, the task won't process and I ProtoProcessor::TaskInvalidError will be logged in the error report

    def validate
      (1..500).include? options[:width]
    end

### Chaining tasks in strategies

    run_task [CropTask, ResizeTask, ZipTask, EmailTask], options

Tasks can be chained and run sequentially as a unit. The input, options and report will be passed down the chain to the last task. The final, composed output and report is then returned to the main strategy and available in the strategy Report.

You can use task chains to process elements in a collection:

    BIG = {:width => 500, :height => 500}
    MEDIUM = {:width => 200, :height => 200}
    SMALL = {:width => 100, :height => 100}

    with_input some_file_here

    # Crop the original
    run_task CropTask, {:square => true}

    # Produce resized versions and store them somewhere
    [BIG, MEDIUM, SMALL].each do |dimensions|
      run_task [ResizeTask, ZipTask, StorageTask], dimensions
    end

If any task in the chain fails the error will be logged. The following tasks will not be processed.

### Stand alone tasks

Tasks are quite simple objects. They expect an array with an input, an options hash and a report hash as an argument and return the same.

    resize = ResizeTask.new([some_file, {:width => 100, :height => 100}, {}])
    resize.run # => [input, options, report]

The task report (just a hash) is populated by tasks and passed along to the next task in the chain, if any. This is a good place to put data resulting from your processing that you want to make available for the next task. You do this with the *report!* shortcut within the process method or any other method you define in your task.

    # ... do some processing
    report! :some_key, 'Some value'

If a task expects a certain key in the report passed from a previous task in a chain, you can make it explicit just like with options:

    expects_report_with :some_key

If :some_key doesn't exist in the passed report, the task will not process and halt any chain it is in.

### Logging

Default to STDOUT. Just add your own logger and logger level.

    ProtoProcessor.logger = Logger.new('my_processor.log')
    ProtoProcessor.logger.level = Logger::ERROR

## TODO

* Improve DSL in strategies
* Better log formatting?

## Copyright

Copyright (c) 2009 Ismael Celis. See LICENSE for details.
