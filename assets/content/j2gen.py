#  Renders text template based on yaml variables
#
# stdin - concatenated yaml
# arg1 - template file
# arg2+ - include paths
# stdout - generated file

import os
import sys
import yaml
from jinja2 import Environment, FileSystemLoader

if os.path.isabs(sys.argv[1]):
    filename = os.path.basename(sys.argv[1])
    paths = [os.path.dirname(sys.argv[1])]
else:
    filename = sys.argv[1]
    paths = [os.getcwd()]

paths += [os.path.dirname(os.getcwd())] + sys.argv[2:]
# print 'paths', paths

variables = yaml.load(sys.stdin.read())
env = Environment(loader = FileSystemLoader(paths), trim_blocks=True, lstrip_blocks=True)
# print 'templates', env.list_templates()
template = env.get_template(filename)
print(template.render(variables))
