module ProtoProcessor
  module Tasks
    
    class InvalidTaskError < StandardError
      def message
        "Invalid task"
      end
    end
    
    class BaseTask
      
      attr_reader :input, :options, :report
      
      # new([input, options, report])
      def initialize(args)
        raise ArgumentError, "You must provide an Enumerable object as argument" unless args.respond_to?(:each)
        raise ArgumentError, "You must provide an array with input, options and report" if args.size < 3
        raise ArgumentError, "A task report must be or behave like a Hash" unless args.last.respond_to?(:[]=)
        @input, @options, @report = args[0].dup, args[1].dup, args[2].dup
        @success = false
      end
      
      def run
        begin
          validate!
          process
          report!(:status, 'SUCCESS')
          @success = true
        rescue StandardError => e
          report!(:status, 'FAILURE')
          report!(:error, {:name => e.class.name, :message => e.message})
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
      
      protected
      
      def validate!
        raise InvalidTaskError unless valid?
      end
      
      def report!(key, value)
        @report[key] = value
      end
      
    end
  end
end