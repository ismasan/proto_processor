module ProtoProcessor
  class Report
    include Enumerable
    
    attr_reader :chain_outputs, :chain_tasks, :error, :chain_statuses
    
    def initialize
      @chain_outputs = {}
      @chain_tasks = {}
      
      @chain_statuses = []
      @error = nil
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
    
    # Major fail at strategy level
    #
    def fail!(exception)
      @error = exception
    end
    
    def successful?
      @error.nil?
    end
    
    def run_report
      @run_report ||= begin
        rep = {}
        @chain_tasks.each do |task_name, runs|
          runs.each_with_index do |r, i|
            rep[:"#{task_name}_#{i}"] = r.map{|t| "#{t.class.name}: #{t.report[:status]}"}
          end
        end
        rep
      end
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
      
      @chain_statuses << tasks.map{|t|t.successful?}
    end
    
  end
end