require 'set'
module ProtoProcessor
  
  module Task
    
    FAILURE = 'FAILURE'
    SUCCESS = 'SUCCESS'
    
    class InvalidTaskError < StandardError
      def message
        "Invalid task"
      end
    end
    
    class MissingParametersError < InvalidTaskError
      def initialize(errors)
        @errors = errors
        super
      end
      
      def message
        "Missing parameters: #{@errors.inspect}"
      end
    end
    
    def self.included(base)
      base.class_eval do
        attr_reader :input, :options, :report, :error
        extend Validations
      end
      #base.extend Validations
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
    
    # class HaltedChainError < StandardError
    #       def message
    #         "Task not run because previous task failed"
    #       end
    #     end
    
    def run
      begin
        log_halt_task and return false if report[:status] == FAILURE
        run_validations!
        before_process
        process
        report!(:status, SUCCESS)
        @success = true
        after_process
      rescue StandardError => e
        # horrible horrible hack to allow Rspec exceptions to bubble up.
        # we can't rescue them because RSpec is only included when running specs
        raise if e.class.name =~ /Spec/
        report!(:status, FAILURE)
        report!(:error, {:name => e.class.name, :message => e.message})
        @error = e
        ProtoProcessor.logger.error "#{self.class.name}: #{e.class.name} => #{e.message}"
        ProtoProcessor.logger.debug e.backtrace.join("\n")
      end
      [@input, @options, @report]
    end
    
    def successful?
      @success
    end
    
    # === Validate in subclasses
    # Example:
    # def validate
    #   options[:some].nil?
    # end
    #
    def valid?
      run_validations!
      true
    rescue InvalidTaskError => e
      false
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
    
    def log_halt_task
      ProtoProcessor.logger.info "#{self.class.name} not run because previous task failed"
    end
    
    def validate
      # implement this in subclasses if needed
      true
    end
    
    def run_validations!
      raise InvalidTaskError unless validate
      errors = []
      self.class.validations.each do |key, required|
        provided = send(key).keys
        missing = required - provided
        errors << "#{key} => #{missing.inspect}" unless required.to_set.subset?(provided.to_set)
      end
      raise MissingParametersError.new(errors) unless errors.empty?
    end
    
    def report!(key, value)
      @report[key] = value
    end
    
    module Validations
      def expects_options_with(*args)
        store_validations_for(:options, args)
      end
      
      def expects_report_with(*args)
        store_validations_for(:report, args)
      end
      
      # {
      #  :options => [:field1, :field2],
      #  :report => [:field1, :field2]
      # }
      def store_validations_for(key, args)
        validations[key] ||= []
        validations[key] += args
      end
      
      def validations
        @validations ||= {}
      end
    end
  end
end