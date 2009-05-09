require File.dirname(__FILE__) + '/spec_helper'

module TVS
  class FooTask
    include ProtoProcessor::Task
    
    expects_options_with :id, :name
    
    expects_report_with :url, :path
    
    def process
      puts options[:id]
    end
    
  end
end

describe 'Task validations' do
  describe "with valid parameters" do
    before do
      @task = TVS::FooTask.new(['',{:id => 1, :name => 'bar'},{:url => 'abc', :path => 'aaa'}])
    end
    
    it "should be valid" do
      @task.should be_valid
    end
  end
  
  describe "with missing parameters" do
    before do
      @task = TVS::FooTask.new(['',{:id => 1},{:path => 'aaa'}])
    end
    
    it "should not be valid" do
      @task.should_not be_valid
    end
    
    it "should not run" do
      @task.should_not_receive(:process)
      @task.run
    end
    
    it "should pass status report = FAILURE" do
      @task.run
      @task.report[:status].should == ProtoProcessor::Task::FAILURE
    end
    
    it "should have error information" do
      @task.run
      @task.report[:error].should_not be_nil
    end
  end
end