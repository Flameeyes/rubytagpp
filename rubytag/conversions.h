/*
 * kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 3;
 */

static inline VALUE cxx2ruby(uint val)
{
    return INT2FIX(val);
}

static inline uint ruby2uint(VALUE rval)
{
    return NUM2INT(rval);
}

static inline bool ruby2bool(VALUE rval)
{
    return (bool)(NUM2INT(rval));
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
