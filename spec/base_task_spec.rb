require File.dirname(__FILE__) + '/spec_helper'

class FooTask < ProtoProcessor::Tasks::BaseTask
  
  def process
    @input << 'a'
    report! :foo, 'foo'
  end
end

class InvalidTask < ProtoProcessor::Tasks::BaseTask
  
  def process
    @input = "I got here"
  end
  
  def valid?
    false
  end
end

describe "BaseTask" do
  before do
    @input = ''
    @options = {}
    @report = {}
    @task = FooTask.new([@input, @options, @report])
  end
  
  it "should raise if less than 3 arguments" do
    lambda {
      FooTask.new(['bar'])
    }.should raise_error(ArgumentError)
  end
  
  it "should raise if argument is not enumerable" do
    lambda {
      FooTask.new(1)
    }.should raise_error(ArgumentError)
  end
  
  it "should raise if report does not cuack like a Hash" do
    lambda {
      FooTask.new(['',{},10])
    }.should raise_error(ArgumentError)
  end
  
  it "should be valid by default" do
    @task.valid?.should be_true
  end
  
  it "should have input, options and report" do
    @task.input.should == @input
    @task.options.should == @options
    @task.report.should == @report
  end
  
  it "should not be successful before running" do
    @task.successful?.should_not be_true
  end
  
  describe "invalid tasks" do
    before do
      @invalid_task = InvalidTask.new(['', {}, @report])
    end
    
    it "should be invalid (duh!)" do
      @invalid_task.valid?.should be_false
    end
    
    it "should not process if not valid" do
      # if the input is modified, it means that it did run #process
      # we can't use expectations because I'm rescueing exceptions, including RSpec ones!
      output = @invalid_task.run
      output.first.should be_empty
      
    end
  end
  
  describe "running" do
    
    it "should invoke :process" do
      @task.should_receive(:process)
      @task.run
    end
    
    it "should return modified input" do
      output = @task.run
      output[0].should == 'a'
    end
    
    it "should return options" do
      output = @task.run
      output[1].should == @options
    end
    
    it "should add stuff to report" do
      output = @task.run
      output[2].should == {:status => 'SUCCESS', :foo => 'foo'}
    end
    
    it "should be successful after running (successfully)" do
      @task.run
      @task.successful?.should be_true
    end
    
  end
  
end

class BarTask < ProtoProcessor::Tasks::BaseTask
  
  def process
    @input << 'b'
    report! :bar, 'bar'
  end
end

describe "decorating the same or other tasks" do
  
  it "should iteratively process" do
    input, options, report = '', {}, {}
    1.upto(5) do |i|
      task = FooTask.new([input, options, report])
      input, options, report = task.run
    end
    
    task = BarTask.new([input, options, report])
    input, options, report = task.run
    
    input.should == 'aaaaab'
    report.should == {:bar=>"bar", :status=>"SUCCESS", :foo=>"foo"}
  end
end
