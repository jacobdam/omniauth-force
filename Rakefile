require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << %w{test lib}
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end
