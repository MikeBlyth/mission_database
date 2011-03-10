require 'rake'
require 'rspec/core/rake_task'

#namespace :spec do
#  desc "Run specs with RCov"
#  RSpec::Core::RakeTask.new('rcov') do |t|
#    t.spec_files = FileList['spec/**/*_spec.rb']
#    t.rcov = true
#    t.rcov_opts = ['--exclude', '\/Library\/Ruby']
#  end
#end

RSpec::Core::RakeTask.new(:rspec_aggregate) do |task|
  task.pattern = 'spec/**/*_spec.rb'
  task.rspec_opts = "--format progress"
  task.rcov = true
  task.rcov_opts = "--exclude osx\/objc,spec,gems\/ " +
                   "--rails --aggregate tmp/coverage.data"
end
