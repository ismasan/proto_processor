module ProtoProcessor
  class Report
    include Enumerable
    
    attr_reader :chain_outputs, :chain_tasks
    
    def initialize
      @chain_outputs = {}
      @chain_tasks = {}
    end
    
    # == Store tasks and output after running task chain
    #
    def report(chain_key, tasks, output)
      report_output(chain_key, output)
      report_tasks(chain_key, tasks)
    end
    
    def each(&block)
      @chain_outputs.each &block
    end
    
    def [](chain_key)
      @chain_outputs[chain_key]
    end
    
    protected
    
    # {
    #   :FooTask => [out1,out2],
    #   :BarTask => [out1,out2]
    # }
    def report_output(chain_key, output)
      @chain_outputs[chain_key] ||= []
      @chain_outputs[chain_key] << output
    end
    
    # {
    #   :FooTask => [[task1,task2],[task1,task2]],
    #   :BarTask => [[task1,task2],[task1,task2]]
    # }
    def report_tasks(chain_key, tasks)
      @chain_tasks[chain_key] ||= []
      @chain_tasks[chain_key] << [*tasks]
    end
    
  end
end