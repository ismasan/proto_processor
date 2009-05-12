# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{proto_processor}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ismael Celis"]
  s.date = %q{2009-05-13}
  s.email = %q{ismaelct@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.markdown"
  ]
  s.files = [
    "LICENSE",
    "README.markdown",
    "Rakefile",
    "VERSION.yml",
    "lib/proto_processor.rb",
    "lib/proto_processor/report.rb",
    "lib/proto_processor/strategy.rb",
    "lib/proto_processor/task.rb",
    "lib/proto_processor/task_runner.rb",
    "spec/base_strategy_spec.rb",
    "spec/base_task_spec.rb",
    "spec/report_spec.rb",
    "spec/spec_helper.rb",
    "spec/task_validations_spec.rb",
    "spec/tasks_runner_spec.rb"
  ]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ismasan/proto_processor}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}
  s.test_files = [
    "spec/base_strategy_spec.rb",
    "spec/base_task_spec.rb",
    "spec/report_spec.rb",
    "spec/spec_helper.rb",
    "spec/task_validations_spec.rb",
    "spec/tasks_runner_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
