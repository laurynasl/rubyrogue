require 'rake'

desc "Run unit tests"
task :test do
  #require 'test/unit'
  puts __FILE__

  Dir.glob(File.join(File.dirname(__FILE__), 'src/test/unit/*.rb')).each do|f|
    puts f
    require f 
  end
end
