FIND_PACKAGE(TagLib REQUIRED)

AUX_SOURCE_DIRECTORY(extras/wavpack TAGLIB_EXTRAS_SOURCES)
AUX_SOURCE_DIRECTORY(extras/speex TAGLIB_EXTRAS_SOURCES)

ADD_CUSTOM_COMMAND(
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/rubytagpp.cc
		${CMAKE_CURRENT_BINARY_DIR}/rubytagpp.h
	COMMAND ${RUBY_EXECUTABLE}
	ARGS -I${GENERATOR_PATH} -C${CMAKE_CURRENT_BINARY_DIR}
		${GENERATOR_PATH}/generator.rb ${CMAKE_CURRENT_SOURCE_DIR}/rubytagpp.yml
	DEPENDS ${GENERATOR_PATH}/generator.rb ${GENERATOR_PATH}/class.rb
		${GENERATOR_PATH}/method.rb ${GENERATOR_PATH}/namespace.rb
		${GENERATOR_PATH}/function.rb
		${CMAKE_CURRENT_SOURCE_DIR}/rubytagpp.yml
)

INCLUDE_DIRECTORIES(${TAGLIB_INCLUDE_DIR} ${RUBY_INCLUDE_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

ADD_LIBRARY(rubytagpp MODULE ${CMAKE_CURRENT_BINARY_DIR}/rubytagpp.cc ${TAGLIB_EXTRAS_SOURCES})
SET_TARGET_PROPERTIES(rubytagpp PROPERTIES PREFIX "")
TARGET_LINK_LIBRARIES(rubytagpp ${TAGLIB_LIBRARIES})

INSTALL(TARGETS rubytagpp DESTINATION ${RUBY_ARCH_DIR})
