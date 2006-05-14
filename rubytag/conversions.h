/*
 * kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 4;
 */

static inline VALUE cxx2ruby(uint val)
{
    return INT2FIX(val);
}

static inline VALUE cxx2ruby(int val)
{
    return INT2FIX(val);
}

static inline VALUE cxx2ruby(const char *val)
{
    return rb_str_new2(val);
}

static inline VALUE cxx2ruby(bool val)
{
    return val ? Qtrue : Qfalse;
}

static inline uint ruby2uint(VALUE rval)
{
    return NUM2INT(rval);
}

static inline int ruby2int(VALUE rval)
{
    return NUM2UINT(rval);
}

static inline bool ruby2bool(VALUE rval)
{
    return !( rval == Qnil || rval == Qfalse );
}

static inline char *ruby2charPtr(VALUE rval)
{
    Check_Type(rval, T_STRING);
    return StringValuePtr(rval);
}

/* Taglib-specific */

static inline VALUE cxx2ruby(TagLib::ByteVector vector)
{
    fprintf(stderr, "Converting vector of %d bytes\n", vector.size());
    return rb_str_new(vector.data(), vector.size());
}

static inline VALUE cxx2ruby(TagLib::String str)
{
    return rb_str_new2(str.toCString());
}

static inline TagLib::String ruby2String(VALUE rval)
{
    Check_Type(rval, T_STRING);
    return TagLib::String(StringValuePtr(rval));
}

static inline TagLib::AudioProperties::ReadStyle ruby2TagLib_AudioProperties_ReadStyle(VALUE rval)
{
    return (TagLib::AudioProperties::ReadStyle)ruby2int(rval);
}

template<typename T> static VALUE cxx2ruby(TagLib::List<T> list)
{
    VALUE rubyarray = rb_ary_new2(list.size());
    typename TagLib::List<T>::Iterator it;

    for(it = list.begin(); it != list.end(); it++ )
    {
        rb_ary_push(rubyarray, cxx2ruby(*it));
    }

    return rubyarray;
}

template<typename Key, typename T> static VALUE cxx2ruby(TagLib::Map<Key, T> map)
{
    VALUE rubyhash = rb_hash_new();
    typename TagLib::Map<Key, T>::Iterator it;

    for(it = map.begin(); it != map.end(); it++)
    {
        rb_hash_aset(rubyhash, cxx2ruby((*it).first), cxx2ruby((*it).second));
    }

    return rubyhash;
}
