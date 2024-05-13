import re, os, sys

def remove_newlines(text):
    return re.sub(r'\n\s*\n', '\n', text)

def remove_comments(text):
    def replacer(match):
        s = match.group(0)
        if s.startswith('/'):
            return " " # note: a space and not an empty string
        else:
            return s
    pattern = re.compile(
        r'//.*?$|/\*.*?\*/|\'(?:\\.|[^\\\'])*\'|"(?:\\.|[^\\"])*"',
        re.DOTALL | re.MULTILINE
    )
    return re.sub(pattern, replacer, text)

try:
    f = sys.argv[1]
    if not os.path.exists (f):
        raise FileNotFoundError(f)
    fp = open (f)
    print (remove_newlines (remove_comments (fp.read())))
    fp.close()
except IndexError:
    exit(-1)
except FileNotFoundError:
    exit(-2)