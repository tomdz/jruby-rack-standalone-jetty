# encoding: utf-8

require 'rubygems'
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "jruby-rack-standalone-jetty"
  gem.homepage = "http://github.com/tomdz/jruby-rack-standalone-jetty"
  gem.license = "ASL 2.0"
  gem.summary = %Q{Simple standalone jetty launcher for jruby rack apps}
  gem.description = %Q{A simple standalone jetty launcher for jruby rack apps}
  gem.email = "tomdzk@gmail.com"
  gem.authors = ["Thomas Dudziak"]
  gem.add_runtime_dependency 'jruby-rack', '~> 1.0.10'
  gem.add_development_dependency "shoulda", ">= 0"
  gem.add_development_dependency "bundler", "~> 1.0.0"
  gem.add_development_dependency "jeweler", "~> 1.6.4"
  gem.add_development_dependency "rcov", ">= 0"
end
Jeweler::RubygemsDotOrgTasks.new

task :default => :build

