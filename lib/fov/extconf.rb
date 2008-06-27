#!/usr/bin/env ruby

require 'mkmf'

dir_config('ruby_fov')
#dir_config('.')
#dir_config('/usr/local/lib')
#find_library('fov', 'fov_settings_init', '/usr/local/lib')
create_makefile('ruby_fov')

