require File.dirname(__FILE__) + '/spec_helper'

module BAS
  class BAS::FooTask
    include ProtoProcessor::Task
    def process
      @input << 'FOO'
      report!(:hello, @input)
    end
  end

  class BAS::BarTask
    include ProtoProcessor::Task
    def process
      @input << 'BAR'
      report!(:hello, @input)
    end
  end
end

class FooBarStrategy
  include ProtoProcessor::Strategy
  
  def options
    options = {
      "original" => 'sample_image.jpg',
      "type" => "FooBar",
      "rotate" => 90,
      "crop" => 'crop_options',
      "sizes" => [{'width' => 100}, {'width' => 200}, {'width' => 300}]
    }
  end
  
  def process
    run_task BAS::FooTask, options
    run_task BAS::BarTask, options
    options['sizes'].each do |size_params|
      run_task BAS::FooTask, size_params
    end
    
  end
  
end

describe "Strategy" do
  before do
    @strategy = FooBarStrategy.new
    @options = @strategy.options
  end
  describe 'running tasks with #run_task' do
    before do
      @mock_task = mock('task', :run => true, :valid? => true)
    end
    
    it "should have a task runner" do
      @strategy.runner.should be_kind_of(ProtoProcessor::TaskRunner)
    end
    
    it "should have an initial report" do
      @strategy.report.should be_kind_of(ProtoProcessor::Report)
    end
    
    it "should delegate to Task Runner with run key, array of one task, input, options and report" do
      @strategy.runner.should_receive(:run_chain).with(:FooTask, [BAS::FooTask], @strategy.current_input, @options, {})
      @strategy.run_task BAS::FooTask, @options
    end
    
    it "should be able to change the input for upcoming tasks" do
      new_input = 'a different input'
      @strategy.runner.should_receive(:run_chain).with(:FooTask, [BAS::FooTask], new_input, @options, {})
      @strategy.with_input new_input
      @strategy.run_task BAS::FooTask, @options
    end
    
    it "should run a task with default input, options and report" do
      BAS::FooTask.should_receive(:new).with([@strategy.current_input,@options,{}]).and_return @mock_task
      @strategy.run_task BAS::FooTask, @options
    end
    
    it "should not run a task if passed options are NIL" do
      BAS::FooTask.should_not_receive(:new)
      @strategy.run_task BAS::FooTask
    end
    
    it "should run a task with passed options" do
      opts = {:blah => 1}
      BAS::FooTask.should_receive(:new).with([@strategy.current_input,opts,{}]).and_return @mock_task
      @strategy.run_task BAS::FooTask, opts
    end
    
  end
  
  describe 'running main process' do
    before do
      @mock_task = mock('task', :run => [@input, @options, {}], :valid? => true)
    end
    
    it "should accumulate result of tasks" do
      pending 'this belongs in the task runner'
      BAS::FooTask.should_receive(:new).exactly(4).and_return @mock_task
      BAS::BarTask.should_receive(:new).exactly(1).and_return @mock_task
      @strategy.run
    end
    
    it "should update values" do
      report = @strategy.run
      @strategy.current_input.should == 'FOOBARFOOFOOFOO'
    end
    
  end
  
end