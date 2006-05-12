ENABLE_TESTING()
SET(RUNTEST_COMMAND ${RUBY_EXECUTABLE} -I${CMAKE_CURRENT_BINARY_DIR}/..)

ADD_TEST(loading ${RUNTEST_COMMAND} test-loading.rb)
ADD_TEST(decompressing ${RUNTEST_COMMAND} test-decompressing.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mp3basic ${RUNTEST_COMMAND} test-mp3basic.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
