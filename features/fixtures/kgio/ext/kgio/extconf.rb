require 'mkmf'
$CPPFLAGS << ' -D_GNU_SOURCE'
create_makefile('kgio_ext')
