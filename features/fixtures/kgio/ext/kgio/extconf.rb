require 'mkmf'

gem 'ast', '~> 2.0'

$CPPFLAGS << ' -D_GNU_SOURCE'
create_makefile('kgio_ext')
