import io, yaml

T_FRC_LUA_CLASS = '''
local ffi = require ('ffi')

ffi.cdef[[
@CDEF@
]]

local lib = ffi.load ('@CLIB@')

local @TYPENAME@ = {}
local @TYPENAME@_mt = {
    __index = @TYPENAME@
}

@METHODS@

ffi.metatype('@CTYPE@', @TYPENAME@_mt)
return @TYPENAME@
'''

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

def cparams (method):
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
        if (n == 0 and use_self) or n > 0:
            ps += ', '
        ps += '%s %s' % (params[p], p)
        n += 1

    return ps

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

    if obj['destructor']:
        out +=  'void %s%sFree (%s* self);' % (ns, typename, ct)
    
    out += '\n\n'

    for k in obj['methods']:
        method = obj['methods'][k]
        rt = method['return_type']
        if rt == None: rt = 'void'
        if rt == 'cptr': rt = ct + "*"
        ps = cparams (method)
        
        out += '%s %s%s%s(%s);\n' % \
            (rt, obj['namespace'], typename, k, ps)
    
    return out

def gen_ffi_methods (obj):
    out = ''
    for k in obj['methods']:
        m = obj['methods'][k]
    
        if m.get ('factory', False):
            continue
    
        sep = ':' 
        if m.get('static', False):
            sep = '.'

        sym = '%s%s' % (lowerfirst (ctype (obj)), k)
        ps = lparams(m)
        out += 'function %s%s%s(%s)\n' % \
                (obj['typename'], sep, lowerfirst (k), ps)
        
        if not m.get('static', False) and not m.get('factory', False):
            if (len(ps.strip()) <= 0):
                ps = 'self'
            else:
                ps = 'self, ' + ps

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
        .replace ('@CLIB@', 'luabot-wpic') \
        .replace ('@METHODS@', gen_ffi_methods (obj)) \
        .replace ('@CDEF@', gen_ffi_cdef (obj))

def gen_ffi_impl (obj):
    typename = obj['typename']
    out = '#include <%s>\n\n' % obj['header']

    ct = ctype(obj)

    out += declare_ffi_ctype (obj) + ';\n\n'

    if obj['destructor']:
        out += '''
void frc%sFree (%s* self) {
    delete (%s*) self;
}
        '''.strip() % (typename, ct, qualified_type (obj))
    
    out += '\n\n'

    for k in obj['methods']:
        method = obj['methods'][k]
        rt = method['return_type']
        if rt == None: rt = 'void'
        ps = cparams (method)
        
        out += '%s %s%s%s (%s);\n' % \
            (rt, obj['namespace'], typename, k, ps)
    
    return out

obj = open_class_def('util/parse.yaml')
print (gen_ffi_class (obj))
exit(0)
