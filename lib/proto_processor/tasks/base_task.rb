module ProtoProcessor
  module Tasks
    class BaseTask
      
      attr_reader :input, :options, :report
      
      def initialize(args)
        raise ArgumentError, "You must provide an Enumerable object as argument" unless args.respond_to?(:each)
        raise ArgumentError, "You must provide an array with input, options and report" if args.size < 3
        @input, @options, @report = args[0].dup, args[1].dup, args[2]
        
        @run_report = {}
        report_key = self.class.name.to_sym
        @report[report_key] = [] unless @report.has_key?(report_key)
        @report[report_key] << @run_report # report for this run, so we can run the same task several times
      end
      
      def run
        process
        [@input, @options, @report]
      end
      
      # Abstract
      #
      def process
        raise NotImplementedError, "You need to implement #process in you tasks"
      end
      
      protected
      
      def report!(key, value)
        @run_report[key] = value
      end
      
    end
  end
end