require 'bundler/gem_tasks'
require 'rake/testtask'

desc 'Make tests output references'
task :make_test_references do
  require_relative 'test/make_test_references'
  make_test_references
  puts
  puts 'Finished generating test references, inspect them for correctness.'
  puts
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

task default: :test
