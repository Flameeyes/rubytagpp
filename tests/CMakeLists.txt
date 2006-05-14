ENABLE_TESTING()
SET(RUNTEST_COMMAND ${RUBY_EXECUTABLE} -I${CMAKE_CURRENT_BINARY_DIR}/..)

ADD_TEST(loading ${RUNTEST_COMMAND} test-loading.rb)
ADD_TEST(decompressing ${RUNTEST_COMMAND} test-decompressing.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

ADD_TEST(fileref ${RUNTEST_COMMAND} test-fileref.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

ADD_TEST(mp3basic ${RUNTEST_COMMAND} test-mp3basic.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mp3tags ${RUNTEST_COMMAND} test-mp3tags.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mp3write ${RUNTEST_COMMAND} test-mp3write.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mp3write-id3v2 ${RUNTEST_COMMAND} test-mp3write-id3v2.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mp3write-id3v1 ${RUNTEST_COMMAND} test-mp3write-id3v1.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mp3write-ape ${RUNTEST_COMMAND} test-mp3write-ape.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

ADD_TEST(mpcbasic ${RUNTEST_COMMAND} test-mpcbasic.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mpctags ${RUNTEST_COMMAND} test-mpctags.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mpcwrite ${RUNTEST_COMMAND} test-mpcwrite.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mpcwrite-ape ${RUNTEST_COMMAND} test-mpcwrite-ape.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(mpcwrite-id3v1 ${RUNTEST_COMMAND} test-mpcwrite-id3v1.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

ADD_TEST(vorbisbasic ${RUNTEST_COMMAND} test-vorbisbasic.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(vorbisfields ${RUNTEST_COMMAND} test-vorbisfields.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(vorbisproperties ${RUNTEST_COMMAND} test-vorbisproperties.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

ADD_TEST(flacbasic ${RUNTEST_COMMAND} test-flacbasic.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(flactags ${RUNTEST_COMMAND} test-flactags.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(flacwrite ${RUNTEST_COMMAND} test-flacwrite.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(flacwrite-id3v2 ${RUNTEST_COMMAND} test-flacwrite-id3v2.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(flacwrite-id3v1 ${RUNTEST_COMMAND} test-flacwrite-id3v1.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(flacwrite-xiph ${RUNTEST_COMMAND} test-flacwrite-xiph.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

ADD_TEST(oggflacbasic ${RUNTEST_COMMAND} test-oggflacbasic.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)
ADD_TEST(oggflacfields ${RUNTEST_COMMAND} test-oggflacfields.rb ${CMAKE_CURRENT_SOURCE_DIR}/emptywave.wav.bz2)

