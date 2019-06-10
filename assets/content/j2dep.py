#  Generates jinja2 template makefile include dependencies
#
# stdin - concatenated yaml
# arg1 - repo directory
# arg2 - template file
# arg3+ - include paths
# stdout - generated makefile

import os
import sys
import yaml
from jinja2 import Environment, FileSystemLoader, meta

def recurse(env, filename, includes):
    source = env.loader.get_source(env, filename)[0]
    parsed = env.parse(source)
    files = list(meta.find_referenced_templates(parsed))
    for file in files:
        if file not in includes:
            includes.append(file)
            recurse(env, file, includes)

if os.path.isabs(sys.argv[2]):
    filepath = os.path.dirname(sys.argv[2])
    filename = os.path.basename(sys.argv[2])
    paths = [filepath, os.path.dirname(os.getcwd())] + sys.argv[3:]
else:
    filename = sys.argv[2]
    paths = [os.getcwd(), os.path.dirname(os.getcwd())] + sys.argv[3:]

targetdir = sys.argv[1]
targetname = os.path.splitext(filename)[0]+".md"
targetfile = os.path.join(targetdir, targetname)

variables = yaml.load(sys.stdin.read())
env = Environment(loader = FileSystemLoader(paths), trim_blocks=True, lstrip_blocks=True)

includes = []
recurse(env, filename, includes)
templates = env.list_templates()

print targetfile + ": \\"
if not len(includes):
    print
    exit(0)

for file in includes:
    for path in paths:
        fullname = os.path.join(path, file)
        if os.path.isfile(fullname):
            print "\t" + fullname + " \\"
            break
print
