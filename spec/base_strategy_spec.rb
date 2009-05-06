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
    options['sizes'].each do |size_params|
      run_task BAS::FooTask, size_params
    end
    
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
      @mock_task = mock('task', :run => true, :valid? => true)
    end
    
    it "should have an initial report" do
      @strategy.report.should == {}
    end
    
    it "should delegate to Task Runner with array of one task, input, options and report" do
      ProtoProcessor::Tasks::Runner.should_receive(:run_chain).with([BAS::FooTask], @input, @options, @strategy.report)
      @strategy.run_task BAS::FooTask, @options
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
    
  end
  
  describe 'running main process' do
    before do
      @strategy = FooBarStrategy.new(@input, @options)
      @mock_task = mock('task', :run => [@input, @options, @strategy.report], :valid? => true)
    end
    
    it "should accumulate result of tasks" do
      pending 'this belongs in the task runner'
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