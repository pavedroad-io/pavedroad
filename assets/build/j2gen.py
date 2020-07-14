#!/usr/bin/env python3
#  Renders text template based on yaml variables
#
# stdin - concatenated yaml
# arg1 - template file
# arg2+ - include paths
# stdout - generated file
# template_file is added to the variables passed to the template file
# template_file passed is the name of the template file with np path

import os
import sys
import yaml
from jinja2 import Environment, FileSystemLoader

def debug(*args, **kwargs):
    global optdebug
    if optdebug:
        print(*args, file=sys.stderr, **kwargs)

if sys.argv[1] == "-d":
    optdebug = True
    filepos = 2
    pathpos = 3
else:
    optdebug = False
    filepos = 1
    pathpos = 2
debug("sys.argv", sys.argv)

if os.path.isabs(sys.argv[filepos]):
    filename = os.path.basename(sys.argv[filepos])
    paths = [os.path.dirname(sys.argv[filepos])]
else:
    filename = sys.argv[filepos]
    paths = [os.getcwd()]
debug("filename", filename)

paths += [os.path.dirname(os.getcwd())] + sys.argv[pathpos:]
debug("paths", paths)

variables = yaml.load(sys.stdin.read())
variables["template_file"] = filename
debug("variables", variables)

env = Environment(loader = FileSystemLoader(paths), trim_blocks=True, lstrip_blocks=True)
debug("templates", env.list_templates())

template = env.get_template(filename)
print(template.render(variables))
