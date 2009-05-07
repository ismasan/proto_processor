require File.dirname(__FILE__) + '/spec_helper'

module RunnerSpecHelper
  class Task1
    include ProtoProcessor::Task
    def process
      report! :common, 1
      report! :a, 1
      @input << 'a'
    end
  end
  class Task2
    include ProtoProcessor::Task
    def process
      report! :common, 2
      report! :b, 2
      @input << 'b'
    end
  end
  class Task3
    include ProtoProcessor::Task
    def process
      report! :common, 3
      report! :c, 3
      @input << 'c'
    end
  end
end
include RunnerSpecHelper
include ProtoProcessor

describe 'TaskRunner' do
  before do
    @input, @options, @report = '', {}, {}
  end
  describe 'running tasks with #run_chain' do
    
    before do
      @task1 = mock('task1', :run => [@input, @options, {:common => 1}])
      @task2 = mock('task2', :run => [@input, @options, {:common => 2}])
      @task3 = mock('task3', :run => [@input, @options, {:common => 3}])
    end
    
    it "should run one task" do
      Task1.should_receive(:new).with([@input, @options, @report]).and_return @task1
      TaskRunner.run_chain([Task1], @input, @options, @report).should == ["", {}, {:common=>1}]
    end
    
    it "should run sequence of nested tasks" do
      Task1.should_receive(:new).with([@input, @options, @report]).and_return @task1
      Task2.should_receive(:new).with([@input, @options, @report.merge(:common => 1)]).and_return @task2
      Task3.should_receive(:new).with([@input, @options, @report.merge(:common => 2)]).and_return @task3
      
      TaskRunner.run_chain([Task1, Task2, Task3], @input, @options, @report)
      
    end
    
  end
  
  it "should call an optional block with run tasks, final output and consolidated report" do 
    collaborator = mock('collaborator')
    collaborator.should_receive(:do_something!).with(2, "ab", {:b=>2, :status=>"SUCCESS", :common=>2, :a=>1})
    TaskRunner.run_chain([Task1, Task2], @input, @options, @report) do |tasks, output, report|
      collaborator.do_something!(tasks.size, output, report)
    end
  end
  
  it "verifies that result is merged hash" do
    TaskRunner.run_chain([Task1, Task2, Task3], @input, @options, @report)\
      .should == ['abc', @options, {:common => 3, :status => 'SUCCESS', :a =>1, :b =>2, :c => 3}]
  end
end