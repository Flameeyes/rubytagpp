/*
 * kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 4;
 */

static inline VALUE cxx2ruby(uint val)
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

static inline bool ruby2bool(VALUE rval)
{
    return (bool)(NUM2INT(rval));
}

static inline char *ruby2charPtr(VALUE rval)
{
    Check_Type(rval, T_STRING);
    return StringValuePtr(rval);
}

/* Taglib-specific */

static inline VALUE cxx2ruby(TagLib::String str)
{
    return rb_str_new2(str.toCString());
}

static inline TagLib::String ruby2String(VALUE rval)
{
    Check_Type(rval, T_STRING);
    return TagLib::String(StringValuePtr(rval));
}
