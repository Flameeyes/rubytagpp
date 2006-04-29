#
# This module finds if RUBY is installed and determines where the include files
# and libraries are. It also determines what the name of the library is. This
# code sets the following variables:
#
#  RUBY_INCLUDE_PATH       = path to where object.h can be found
#  RUBY_EXECUTABLE         = full path to the ruby binary
#
FIND_PROGRAM(RUBY_EXECUTABLE
  NAMES ruby1.8 ruby18 ruby
  PATHS
  /usr/bin
  /usr/local/bin
)

#   RUBY_ARCHDIR=`$RUBY -r rbconfig -e 'printf("%s",Config::CONFIG@<:@"archdir"@:>@)'`
#   RUBY_SITEARCHDIR=`$RUBY -r rbconfig -e 'printf("%s",Config::CONFIG@<:@"sitearchdir"@:>@)'`
#   RUBY_SITEDIR=`$RUBY -r rbconfig -e 'printf("%s",Config::CONFIG@<:@"sitelibdir"@:>@)'`
#   RUBY_LIBDIR=`$RUBY -r rbconfig -e 'printf("%s",Config::CONFIG@<:@"libdir"@:>@)'`
#   RUBY_LIBRUBYARG=`$RUBY -r rbconfig -e 'printf("%s",Config::CONFIG@<:@"LIBRUBYARG_SHARED"@:>@)'`

EXEC_PROGRAM(${RUBY_EXECUTABLE}
	ARGS -r rbconfig -e 'puts Config::CONFIG["archdir"]'
	OUTPUT_VARIABLE RUBY_ARCH_DIR)
SET(RUBY_ARCH_DIR "${RUBY_ARCH_DIR}" CACHE_INTERNAL "")
EXEC_PROGRAM(${RUBY_EXECUTABLE}
	ARGS -r rbconfig -e 'puts Config::CONFIG["libdir"]'
	OUTPUT_VARIABLE RUBY_POSSIBLE_LIB_PATH)

FIND_PATH(RUBY_INCLUDE_PATH ruby.h
  ${RUBY_ARCH_DIR})

FIND_LIBRARY(RUBY_LIBRARY
  NAMES ruby18 ruby
  PATHS ${RUBY_POSSIBLE_LIB_PATH}
  )

MARK_AS_ADVANCED(
  RUBY_EXECUTABLE
  RUBY_LIBRARY
  RUBY_INCLUDE_PATH
  RUBY_ARCH_DIR
  )
