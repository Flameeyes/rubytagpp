# - Try to find TagLib
# Once done this will define
#
#  TAGLIB_FOUND - system has TagLib
#  TAGLIB_INCLUDE_DIR - the TagLib include directory
#  TAGLIB_LIBRARIES - Link these to TagLib
#  TAGLIB_DEFINITIONS - Compiler switches required for using TagLib
#

IF (DEFINED CACHED_TAGLIB)

  # in cache already
  IF ("${CACHED_TAGLIB}" STREQUAL "YES")
    SET(TAGLIB_FOUND TRUE)
  ENDIF ("${CACHED_TAGLIB}" STREQUAL "YES")

ELSE (DEFINED CACHED_TAGLIB)

  IF (NOT WIN32)
    # use pkg-config to get the directories and then use these values
    # in the FIND_PATH() and FIND_LIBRARY() calls
    INCLUDE(UsePkgConfig)
    PKGCONFIG(taglib _TagLibIncDir _TagLibLinkDir _TagLibLinkFlags _TagLibCflags)
    set(TAGLIB_DEFINITIONS ${_TagLibCflags})
  ENDIF (NOT WIN32)

  FIND_PATH(TAGLIB_INCLUDE_DIR taglib.h
    ${_TagLibIncDir}/taglib
    /usr/include/taglib
    /usr/local/include/taglib
  )
  
  FIND_LIBRARY(TAGLIB_LIBRARIES NAMES tag taglib libtag
    PATHS
    ${_TagLibLinkDir}
    /usr/lib
    /usr/local/lib
  )
  
  if (TAGLIB_INCLUDE_DIR AND TAGLIB_LIBRARIES)
     set(TAGLIB_FOUND TRUE)
     set(CACHED_TAGLIB "YES")
  else (TAGLIB_INCLUDE_DIR AND TAGLIB_LIBRARIES)
     set(CACHED_TAGLIB "NO")
  endif (TAGLIB_INCLUDE_DIR AND TAGLIB_LIBRARIES)
  
  if (TAGLIB_FOUND)
    if (NOT TagLib_FIND_QUIETLY)
    message(STATUS "Found TagLib: ${TAGLIB_LIBRARIES}")
    endif (NOT TagLib_FIND_QUIETLY)
  else (TAGLIB_FOUND)
    if (TagLib_FIND_REQUIRED)
    message(FATAL_ERROR "Could NOT find TagLib")
    endif (TagLib_FIND_REQUIRED)
  endif (TAGLIB_FOUND)
  
  set(CACHED_TAGLIB ${CACHED_TAGLIB} CACHE INTERNAL "If taglib was checked")
  MARK_AS_ADVANCED(TAGLIB_INCLUDE_DIR TAGLIB_LIBRARIES)
  
ENDIF (DEFINED CACHED_TAGLIB)
