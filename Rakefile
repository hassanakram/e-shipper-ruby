#!/usr/bin/env rake
require 'bundler/gem_tasks'
require 'rake/testtask'

namespace :test do
  Rake::TestTask.new :all do |test|
    test.libs << 'lib'
    test.pattern = 'test/**/*_test.rb'
  end
  
  Rake::TestTask.new :unit do |test|
    test.libs << 'lib'
    test.pattern = 'test/unit/*_test.rb'
  end
  
  Rake::TestTask.new :functional do |test|
    test.libs << 'lib'
    test.pattern = 'test/functional/*_test.rb'
  end
end