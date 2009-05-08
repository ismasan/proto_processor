module ProtoProcessor
  
  module Task
    
    class InvalidTaskError < StandardError
      def message
        "Invalid task"
      end
    end
    
    def self.included(base)
      base.class_eval do
        attr_reader :input, :options, :report, :error
      end
    end
    
    # new([input, options, report])
    def initialize(args)
      raise ArgumentError, "You must provide an Enumerable object as argument" unless args.respond_to?(:each)
      raise ArgumentError, "You must provide an array with input, options and report" if args.size < 3
      raise ArgumentError, "A task report must be or behave like a Hash" unless args.last.respond_to?(:[]=)
      @input, @options, @report = args[0], args[1].dup, args[2].dup
      @success = false
      @error = nil
    end
    
    class HaltedChainError < StandardError
      def message
        "Task not run because previous task failed"
      end
    end
    
    def run
      begin
        raise HaltedChainError if report[:status] == 'FAILURE'
        validate!
        before_process
        process
        report!(:status, 'SUCCESS')
        @success = true
        after_process
      rescue StandardError => e
        # horrible horrible hack to allow Rspec exceptions to bubble up.
        # we can't rescue them because RSpec is only included when running specs
        raise if e.class.name =~ /Spec/
        report!(:status, 'FAILURE')
        report!(:error, {:name => e.class.name, :message => e.message})
        @error = e
        ProtoProcessor.logger.debug "ERROR: #{self.class.name}: #{e.class.name} => #{e.message}"
        ProtoProcessor.logger.debug e.backtrace.join("\n")
      end
      [@input, @options, @report]
    end
    
    def successful?
      @success
    end
    
    # === Validate in subclasses
    # Example:
    # def valid?
    #   options[:some].nil?
    # end
    #
    def valid?
      true
    end
    
    # Abstract
    #
    def process
      raise NotImplementedError, "You need to implement #process in you tasks"
    end
    
    def before_process
      true
    end
    
    def after_process
      true
    end
    
    # Update input so it's passed to the next task
    #
    def update_input!(new_input)
      @input = new_input
    end
    
    protected
    
    def validate!
      raise InvalidTaskError unless valid?
    end
    
    def report!(key, value)
      @report[key] = value
    end
    
  end
end