module ProtoProcessor
  ROOT = File.dirname(__FILE__)
  $: << File.join(ROOT, 'proto_processor')
  
  autoload :Task, 'task'
  autoload :Strategy, 'strategy'
  autoload :TaskRunner, 'task_runner'
  autoload :Report, 'report'
end