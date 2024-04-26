from cxxheaderparser.simple import parse_string
from cxxheaderparser.simple import ParsedData
from cxxheaderparser.simple import Method

from pcpp import Preprocessor

import io, re, os
from os.path import join
from os.path import expanduser

def find_include_file (inc, path):
    for root, dirs, files in os.walk(path):
        for f in files:
            fpath = join (root, f)
            if fpath.endswith (inc):
                return fpath
    return None

def luabot_include_path():
    return expanduser ("~/SDKs/luabot/linux64/include")

def linux64_cpp_includes():
    incs = '''
        /usr/include/c++/12
        /usr/include/x86_64-linux-gnu/c++/12
        /usr/include/c++/12/backward
        /usr/lib/gcc/x86_64-linux-gnu/12/include
        /usr/local/include
        /usr/include/x86_64-linux-gnu
        /usr/include
    '''.split()

    base = luabot_include_path()
    
    incs.append (join (base, 'luajit-2.1'))
    
    wpislugs = '''
        apriltag
        cameraserver
        cscore
        hal
        luajit-2.1
        ntcore
        wpilibc
        wpimath
        wpinet
        wpilibNewCommands
        wpiutil
    '''.split()
    # cscore
    for s in wpislugs:
        incs.append (join (base, s))
    
    return incs

def process (inc: str):
    file = open (find_include_file (inc, luabot_include_path()), 'r')

    p = Preprocessor()

    for inc in linux64_cpp_includes():
        p.add_path (inc)
    
    p.line_directive = None
    p.include_depth = 0
    p.passthru_includes = re.compile('')
    p.parse (file.read())
    oh = io.StringIO()
    p.write (oh)
    file.close()
    return oh.getvalue()

# print (oh.getvalue())
# if oh.getvalue() != self.output:
#     print("Should be:\n" + self.output, file = sys.stderr)
#     print("\n\nWas:\n" + oh.getvalue(), file = sys.stderr)

def first_class(data: ParsedData):
    return data.namespace.namespaces["frc"].classes[0]

def first_class_name(data: ParsedData):
    return first_class(data).class_decl.typename.segments[0].name

def cdeclare (cxxtype: str, ctype: str, method: Method):
    name = m.name.segments[0].name
    out = '%s frc%s%s (' % (method.return_type.format(), cxxtype, name)
    
    out += ctype + "* self"
    if len (method.parameters) > 0:
        out += ", "
    
    for param in method.parameters:
        out += param.format()
        if param != method.parameters[-1]:
            out += ', '
    
    out += ')'
    return out

data  = parse_string (process ('frc/geometry/Pose2d.h'))
name  = first_class_name (data)
klass = first_class (data)

# parsed_data = parse_file ("out.h")
# parsed_data = parse_file("/home/mfisher/SDKs/luabot/linux64/include/luajit-2.1/lua.h")

cxxtype = name
ctype = "Frc%s" % name
cptr = ctype + "*"

out = io.StringIO()

out.write ('''#pragma once

#include <frc/GenericHID.h>

using frc::GenericHID;

#ifdef __cplusplus
extern "C" {
#endif

typedef void %s;
''' % (ctype))

for m in klass.methods:
    method = m.name.segments[0].name
    if method == cxxtype or method == "~" + cxxtype or 'operator' in method:
        continue
    print (cdeclare (cxxtype, ctype, m))
    continue

    for param in m.parameters:
        out.write (param.format() + "\n")

    rtype = m.return_type
    if rtype != None:
        rtype = rtype.typename.segments[0].name
    
    if rtype == cxxtype:
        rtype = ctype + "*"
    elif rtype == 'units':
        rtype = 'double'
    
    if rtype == None:
        rtype = "void"
    
    cmethod = "frc%s%s" % (cxxtype, method)
    cdeclare = "%s %s (%s self)" % (rtype, cmethod, cptr)

    out.write ('''%s {
    ((%s*)self)->%s();
}\n\n''' % (cdeclare, cxxtype, method))
    

out.write ('''#ifdef __cplusplus
}
#endif
''')

print (out.getvalue())