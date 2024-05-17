import io, yaml
import os

T_FRC_LUA_CLASS = '''
local ffi = require ('ffi')

ffi.cdef[[
@CDEF@
]]

local lib = ffi.load ('@CLIB@')

---@TYPENAME@ wrapper
---@class @TYPENAME@
local @TYPENAME@ = {}
local @TYPENAME@_mt = {
    __index = @TYPENAME@
}

@CTOR@

@METHODS@

ffi.metatype('@CTYPE@', @TYPENAME@_mt)
return @TYPENAME@
'''

def parse_options():
    from optparse import OptionParser

    parser = OptionParser()
    parser.add_option('-l', '--list', dest='list', help='List files in dir', 
                      action='store_true', default=False)
    parser.add_option("-b", "--bindings-dir", dest="bindings_dir",
        help="Path to bindings YAML and other files", 
        default='bindings')
    parser.add_option("-f", "--format", dest="format",
        help="Output format to generate", default='lua')
    parser.add_option("-o", "--out", dest="output",
        help="write report to FILE",
        default='',
        metavar="FILE")

    return parser.parse_args()

def lowerfirst(input: str):
    return input[0].lower() + input[1:]

def open_class_def (file):
    with open(file) as stream:
        obj = yaml.safe_load (stream)
        return obj

def qualified_type (obj):
    return '%s::%s' % (obj['namespace'], obj['typename'])

def cprefix (obj):
    return obj['namespace'].title()

def ctype (obj):
    return '%s%s' % (cprefix(obj), obj['typename'])

def lparams (method):
    params = method.get ('params', {})

    ps = ''

    n = 0
    for p in params:
        if n > 0: ps += ', '
        ps += '%s' % (p)
        n += 1

    return ps

def cparams (obj, method):
    params = method.get ('params', {})
    static = method.get ('static', False)
    factory = method.get ('factory', False)
    use_self = not static and not factory
    ps = ''

    if use_self:
        ps = '%s* self' % ctype (obj)
        if method.get ('const', False):
            ps = 'const ' + ps

    n = 0
    for p in params:
        t = params[p]
        if t == 'const-cptr':
            t = 'const %s*' % ctype(obj)
        
        if (n == 0 and use_self) or n > 0:
            ps += ', '
        ps += '%s %s' % (t, p)
        n += 1

    return ps

def csymbol (obj, ms):
    return '%s%s%s' % (obj['namespace'], obj['typename'], ms)
    
def declare_opaque_ctype (obj):
    return 'typedef void %s' % ctype(obj)

def declare_ffi_ctype (obj):
    ct = ctype (obj)
    return 'typedef struct %s %s' % (ct, ct)

def gen_ffi_cdef (obj):
    ns = obj['namespace']
    typename = obj['typename']
    ct = ctype(obj)
    out = declare_ffi_ctype (obj) + ';\n\n'

    if obj.get ('destructor', True):
        out +=  'void %s(%s* self);' % (csymbol (obj,'Free'), ct)
    
    out += '\n\n'

    for k in obj['methods']:
        method = obj['methods'][k]
        rt = method.get('return_type')
        if rt == None: rt = 'void'
        if rt == 'cptr': rt = ct + "*"
        ps = cparams (obj, method)
        
        out += '%s %s%s%s(%s);\n' % \
            (rt, obj['namespace'], typename, k, ps)
    
    return out.strip()

def gen_ffi_ctor_metatable (obj):
    out = '''
setmetatable(%s, {
    __call = function (T, ...)
        return lib.%s (...)
    end
})
''' % (obj['typename'], csymbol (obj, 'New'))

    return out.strip()


def gen_ffi_ctor (obj):
    out = '''
function %s.new(...)
    return lib.%s (...)
end
''' % (obj['typename'], csymbol (obj, 'New'))

    return out.strip()

def gen_ffi_methods (obj):
    out = ''
    for k in obj['methods']:
        m = obj['methods'][k]
    
        if m.get ('factory', False):
            continue
    
        sep = ':' 
        if m.get('static', False):
            sep = '.'

        sym = csymbol(obj, k)
        ps = lparams(m)
        out += 'function %s%s%s(%s)\n' % \
                (obj['typename'], sep, lowerfirst (k), ps)
        
        if not m.get('static', False) and not m.get('factory', False):
            if (len(ps.strip()) <= 0):
                ps = 'self'
            else:
                ps = 'self, ' + ps

        ccall = m.get('lua_body', '').strip()
        if len(ccall) <= 0:
            ccall = 'lib.%s(%s)' % (sym, ps)
            rt = m.get ('return_type', 'void').strip()
            if rt != 'void':
                ccall = 'return ' + ccall

        out += '    %s\n' % ccall

        out += 'end\n\n'
    
    return out.strip()

def gen_ffi_class (obj):
    return T_FRC_LUA_CLASS \
        .replace ('@CTYPE@', ctype(obj)) \
        .replace ('@TYPENAME@', obj['typename']) \
        .replace ('@CLIB@', 'luabot') \
        .replace ('@CDEF@', gen_ffi_cdef (obj)) \
        .replace ('@CTOR@', gen_ffi_ctor (obj)) \
        .replace ('@METHODS@', gen_ffi_methods (obj))

def gen_ffi_impl (obj):
    typename = obj['typename']
    qtypename = qualified_type (obj)

    out = '#include <wpi/SymbolExports.h>\n'
    out += '#include <%s>\n\n' % obj['header']

    out += 'extern "C" { \n\n'

    ct = ctype(obj)

    out += declare_opaque_ctype (obj) + ';\n\n'

    if obj.get ('destructor', True):
        out += '''
void frc%sFree (%s* self) {
    delete (%s*) self;
}
        '''.strip() % (typename, ct, qtypename)
    
    out += '\n\n'

    for k in obj['methods']:
        method = obj['methods'][k]
        stub = method.get('stub', False)

        rt = method.get('return_type')
        if rt == None: rt = 'void'
        if rt == 'cptr': rt = ctype(obj) + '*'

        ps = cparams (obj, method)
        ls = lparams (method)
        cbody = method.get('c_body', '')

        if method.get('factory', False) and not len(cbody) > 0:
            out += '%s %s%s%s (%s) {\n' % \
                (rt, obj['namespace'], typename, k, ps)
            
            if not stub:
                out += '    return (%s*) new %s (%s);\n' \
                    % (ctype(obj), qtypename, ls)
            
            out += '}\n\n'
        elif method.get ('static', False):
            out += '%s %s%s%s (%s) {\n' % \
                (rt, obj['namespace'], typename, k, ps)
            
            if len(cbody) > 0:
                out +=  cbody + '\n'
            elif not stub:
                out += '    return %s::%s(%s);\n' \
                    % (qtypename, k, ls)
            
            out += '}\n\n'
        else:
            out += '%s %s%s%s (%s) {\n' % \
                (rt, obj['namespace'], typename, k, ps)
            if len(cbody) > 0:
                out +=  cbody + '\n'
            elif not stub:
                out += '    return ((%s*) self)->%s (%s);\n' \
                    % (qtypename, k, ls)
            
            out += '}\n\n'
    
    out += '} // extern "C"\n' # extern C
    return out

def find_resources (dir: str, types=['yaml', 'lua']) -> list[str]:
    from glob import glob
    from os.path import exists
    
    root = dir
    if not isinstance(root, str) or len(root) <= 0 or not exists(root):
        raise FileNotFoundError('%s' % root)
    
    out = []
    for t in types:
        out += glob ('%s/**/*.%s' % (root, t), 
                    root_dir='', recursive=True)
    return out

def find_yaml_defs(dir: str) -> list[str]:
    return find_resources (dir, ['yaml'])

def process (opts, file, output = ''):
    obj = open_class_def (file)
    if opts.format != 'lua':
        txt = gen_ffi_impl (obj)
        if len(output) > 0:
            with open (output, 'w') as f:
                f.write (txt)
                f.close()
        else:
            print(txt)
    else:
        txt = gen_ffi_class (obj)
        if len(output) > 0:
            with open (output, 'w') as f:
                f.write (txt)
                f.close()
        else:
            print(txt)

def renderall (opts, defs = []):
    dir = os.path.abspath (opts.bindings_dir)
    have_output = len(opts.output) > 0
    tgt = os.path.abspath (opts.output)

    # print ('DIR:', dir)
    # print()

    if os.path.exists (tgt) and not os.path.isdir (tgt):
        raise NotADirectoryError (tgt)
    if not os.path.exists (tgt):
        os.makedirs (tgt)
    
    if len(defs) <= 0:
        defs = find_yaml_defs (dir)

    if not have_output:
        for f in defs:
            af = os.path.abspath (f)
            process (opts, af)
    else:
        for f in defs:
            # print (' -', f)
            af = os.path.abspath (f)
            stem, ext = os.path.splitext (af)

            nd = af.replace (dir, '')
            if nd.startswith('/') or nd.startswith('\\'):
                nd = nd[1:]
            fn = os.path.basename (nd)
            
            should_process = ext == '.yaml' or ext == '.yml'
            if should_process:
                if opts.format == 'lua':
                    fn = fn.replace('yaml', 'lua')
                elif opts.format == 'c':
                    fn = fn.replace('yaml', 'cpp')
                else:
                    raise Exception("Invalid output format: " + opts.format)
            
            nd = os.path.dirname (os.path.join (tgt, nd))
            nf = os.path.join (nd, fn)

            # print (f)
            # print (af)
            # print (nd)
            # print ('->', nf)
            # print()
            # continue

            if not os.path.exists (nd):
                os.makedirs (nd)
            if should_process:
                process (opts, af, nf)
            else:
                import shutil
                if os.path.exists (nf):
                    os.remove (nf)
                shutil.copy2 (af, nf)

def print_modules (dir):
    from pathlib import Path
    if not os.path.isdir (dir):
        raise NotADirectoryError(dir)
    adir = os.path.abspath (dir)
    out = []
    for f in find_resources (adir):
        f = os.path.relpath (f, adir)
        out.append(f)
    out.sort()
    for f in out:
        s = "'" + os.path.splitext (f)[0] + "'"
        s = s.replace ('/', '.')
        if f != out[-1]:
            s += ','
        print (s)
    exit(0)

def main():
    opts, args = parse_options()
    if (opts.list):
        if not os.path.isdir (args[0]):
            raise NotADirectoryError(args[0])
        adir = os.path.abspath (args[0])
        out = []
        for f in find_resources (adir):
            f = os.path.relpath (f, adir)
            out.append(f)
        out.sort()
        for f in out:
            print (f)
        exit(0)

    if len(args) == 1:
        if os.path.isdir(args[0]):
            renderall (opts)
        else:
            process (opts, args[0], opts.output)
    elif len(args) <= 0:
        renderall (opts)
    elif len(args) > 0:
        renderall (opts, args)
    else:
        raise Exception()

    exit(0)

if __name__ == '__main__':    
    main()
