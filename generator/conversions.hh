// Flameeyes's C++<->Ruby bindings generator
// Copyright (C) 2006, Diego "Flameeyes" Pettenò
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this generator; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

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
    if ( ! val ) return Qnil;
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

// kate: encoding UTF-8; remove-trailing-space on; replace-trailing-space-save on; space-indent on; indent-width 4;
