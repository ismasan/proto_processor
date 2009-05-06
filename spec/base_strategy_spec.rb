require File.dirname(__FILE__) + '/spec_helper'

module BAS
  class BAS::FooTask < ProtoProcessor::Tasks::BaseTask
    def process
      @input << 'FOO'
      report!(:hello, @input)
    end
  end

  class BAS::BarTask < ProtoProcessor::Tasks::BaseTask
    def process
      @input << 'BAR'
      report!(:hello, @input)
    end
  end
end

class FooBarStrategy < ProtoProcessor::Strategies::BaseStrategy
  
  def process
    run_task BAS::FooTask, options
    run_task BAS::BarTask, options
    run_task BAS::FooTask, options['sizes'] # iterate sizes
  end
  
end

describe "BaseStrategy" do
  
  before do 
    @input = ''
    @options = {
      "original" => 'sample_image.jpg',
      "type" => "FooBar",
      "rotate" => 90,
      "crop" => 'crop_options',
      "sizes" => [{'width' => 100}, {'width' => 200}, {'width' => 300}]
    }
  end
  
  describe 'factory' do
    it "should resolve strategy class according to 'type' option" do
      ProtoProcessor::Strategies.create(@options.delete('type'), @input).should be_kind_of(FooBarStrategy)
    end

    it "should instantiate concrete strategy with options" do
      FooBarStrategy.should_receive(:new).with(@input, @options)
      ProtoProcessor::Strategies.create(@options.delete('type'), @input, @options)
    end
  end
  
  describe 'running tasks with #run_task' do
    before do
      @strategy = FooBarStrategy.new(@input, @options)
      @mock_task = mock('task', :run => true)
    end
    
    it "should have an initial report" do
      @strategy.report.should == {}
    end
    
    it "should run a task with default input, options and report" do
      BAS::FooTask.should_receive(:new).with([@input,@options,@strategy.report]).and_return @mock_task
      @strategy.run_task BAS::FooTask, @options
    end
    
    it "should not run a task if passed options are NIL" do
      BAS::FooTask.should_not_receive(:new)
      @strategy.run_task BAS::FooTask
    end
    
    it "should run a task with passed options" do
      opts = {:blah => 1}
      BAS::FooTask.should_receive(:new).with([@input,opts,@strategy.report]).and_return @mock_task
      @strategy.run_task BAS::FooTask, opts
    end
    
    it "should iterate options with task if passed an array of options" do
      BAS::FooTask.should_receive(:new).exactly(3).and_return @mock_task
      @strategy.run_task BAS::FooTask, @options['sizes']
    end
    
    it "should intantiate and run the task" do
      BAS::FooTask.stub!(:new).and_return @mock_task
      @mock_task.should_receive(:run)
      @strategy.run_task BAS::FooTask, {}
    end
    
    it "should run a task with input and report" do
      @strategy.run_task BAS::FooTask, {}
      @strategy.report.has_key?(:FooTask).should be_true
    end
    
    describe "with an optional block" do
      before do
        BAS::FooTask.stub!(:new).and_return @mock_task
        @some_collaborator = mock('Collaborator')
      end
      
      it "should pass task to block if block given" do
        @some_collaborator.should_receive(:do_something).with(@mock_task)
        @strategy.run_task BAS::FooTask, {} do |task|
          @some_collaborator.do_something(task)
        end
      end
    end
    
  end
  
  describe 'running main process' do
    before do
      @strategy = FooBarStrategy.new(@input, @options)
      @mock_task = mock('task', :run => [@input, @options, @strategy.report])
    end
    
    it "should accumulate result of tasks" do
      BAS::FooTask.should_receive(:new).exactly(4).and_return @mock_task
      BAS::BarTask.should_receive(:new).exactly(1).and_return @mock_task
      @strategy.run
    end
    
    it "should update values" do
      report = @strategy.run
      @strategy.input.should == 'FOOBARFOOFOOFOO'
    end
    
  end
  
end