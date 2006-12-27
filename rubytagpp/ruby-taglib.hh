/* Simple wrap-aroudn TagLib .. */

#if __GNUC__ >= 4
# pragma GCC visibility push(default)
#endif

#include <taglib.h>
#include <tag.h>
#include <id3v1tag.h>
#include <id3v2tag.h>
#include <xiphcomment.h>
#include <apetag.h>
#include <tfile.h>
#include <flacfile.h>
#include <mpcfile.h>
#include <mpegfile.h>
#include <oggfile.h>
#include <oggflacfile.h>
#include <vorbisfile.h>
#include <vorbisproperties.h>
#include <fileref.h>
#include <tlist.h>
#include <id3v2frame.h>
#include <textidentificationframe.h>
#include <attachedpictureframe.h>
#include <commentsframe.h>
#include <relativevolumeframe.h>
#include <uniquefileidentifierframe.h>
#include <unknownframe.h>
#include <mpegheader.h>
#include <apefooter.h>
#include <id3v2footer.h>
#include <id3v2extendedheader.h>

#if __GNUC__ >= 4
# pragma GCC visibility pop
#endif

/* These are the extras */
#include "extras/wavpack/wvfile.h"

using TagLib::String;
using TagLib::StringList;
using TagLib::ByteVector;
