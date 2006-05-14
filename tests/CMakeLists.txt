ENABLE_TESTING()
SET(RUNTEST_COMMAND ${RUBY_EXECUTABLE} -I${CMAKE_CURRENT_BINARY_DIR}/..)

ADD_TEST(loading ${RUNTEST_COMMAND} test-loading.rb)
ADD_TEST(decompressing ${RUNTEST_COMMAND} test-decompressing.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

ADD_TEST(fileref ${RUNTEST_COMMAND} test-fileref.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

ADD_TEST(mp3basic ${RUNTEST_COMMAND} test-mp3basic.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mp3tags ${RUNTEST_COMMAND} test-mp3tags.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mp3writesave ${RUNTEST_COMMAND} test-mp3writesave.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

ADD_TEST(mpcbasic ${RUNTEST_COMMAND} test-mpcbasic.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mpctags ${RUNTEST_COMMAND} test-mpctags.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

ADD_TEST(oggbasic ${RUNTEST_COMMAND} test-oggbasic.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(oggfields ${RUNTEST_COMMAND} test-oggfields.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(oggproperties ${RUNTEST_COMMAND} test-oggproperties.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

ADD_TEST(flacbasic ${RUNTEST_COMMAND} test-flacbasic.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(flactags ${RUNTEST_COMMAND} test-flactags.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

ADD_TEST(oggflacbasic ${RUNTEST_COMMAND} test-oggflacbasic.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(oggflacfields ${RUNTEST_COMMAND} test-oggflacfields.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

