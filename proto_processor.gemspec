# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{proto_processor}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ismael Celis"]
  s.date = %q{2009-05-07}
  s.email = %q{ismaelct@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION.yml",
    "lib/proto_processor.rb",
    "lib/proto_processor/report.rb",
    "lib/proto_processor/strategy.rb",
    "lib/proto_processor/task.rb",
    "lib/proto_processor/task_runner.rb",
    "spec/base_strategy_spec.rb",
    "spec/base_task_spec.rb",
    "spec/demo.rb",
    "spec/proto_processor_spec.rb",
    "spec/report_spec.rb",
    "spec/spec_helper.rb",
    "spec/tasks_runner_spec.rb",
    "spec/test_images/test.jpg",
    "spec/test_images/test_200x200.jpg",
    "spec/test_images/test_300x300.jpg",
    "spec/test_images/test_400x400.jpg",
    "spec/test_images/tmp.jpg"
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
    "spec/demo.rb",
    "spec/proto_processor_spec.rb",
    "spec/report_spec.rb",
    "spec/spec_helper.rb",
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
