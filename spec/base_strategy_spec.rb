require File.dirname(__FILE__) + '/spec_helper'

class FooStrategy < ProtoProcessor::Strategies::BaseStrategy
  
  def process
    #run_task FooTask
  end
  
end

describe "BaseStrategy" do
  
  before do 
    @input = mock('A file')
    @options = {
      "original" => 'sample_image.jpg',
      "type" => "Foo",
      "rotate" => 90,
      "crop" => :crop_options,
      "sizes" => [:size1, :size2, :size3]
    }
  end
  
  describe 'factory' do
    it "should resolve strategy class according to 'type' option" do
      ProtoProcessor::Strategies.create(@options.delete('type'), @input).should be_kind_of(FooStrategy)
    end

    it "should instantiate concrete strategy with options" do
      FooStrategy.should_receive(:new).with(@input, @options)
      ProtoProcessor::Strategies.create(@options.delete('type'), @input, @options)
    end
  end
  
  describe 'running tasks' do
    before do
      @strategy = FooStrategy.new(@options)
    end
    
    it "run the tasks" do
      
    end
  end
  
  
end