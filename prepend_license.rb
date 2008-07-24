#!/usr/bin/env ruby

def add_license(name, license)
  text = File.open(name, 'r'){|f| f.read}
  full_text = license + text
  File.open(name, 'w'){|f| f.write(full_text)}
end

files = File.open('files'){|f| f.read}.split("\n")
license = File.open('license_template'){|f| f.read}

files.each do |filename|
  add_license(filename, license)
end


