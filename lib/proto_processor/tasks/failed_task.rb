class ProtoProcessor::Tasks::FailedTask < ProtoProcessor::Tasks::BaseTask
  def process
    raise 'Oh no something went wrong!'
  end
end