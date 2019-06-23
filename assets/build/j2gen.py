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

# print >> sys.stderr, "sys.argv", sys.argv

if os.path.isabs(sys.argv[1]):
    filename = os.path.basename(sys.argv[1])
    paths = [os.path.dirname(sys.argv[1])]
else:
    filename = sys.argv[1]
    paths = [os.getcwd()]
# print >> sys.stderr, "fullname", fullname

paths += [os.path.dirname(os.getcwd())] + sys.argv[2:]
# print >> sys.stderr, "paths", paths

variables = yaml.load(sys.stdin.read())
variables["template_file"] = filename
# print >> sys.stderr, "variables", variables

env = Environment(loader = FileSystemLoader(paths), trim_blocks=True, lstrip_blocks=True)
# print >> sys.stderr, "templates", env.list_templates()

template = env.get_template(filename)
print(template.render(variables))
