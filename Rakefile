require 'rake'

desc "Run unit tests"
task :spec do
  system 'spec --color --diff unified spec/*/*_spec.rb'
end

desc "Compile fov library"
task :build do
  system 'cd lib/fov; ./extconf.rb; make'
end
