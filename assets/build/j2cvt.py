# usage: python j2cvt.py variable-file input-template output-file

import sys
import yaml
from jinja2 import Environment, FileSystemLoader

variables = yaml.load(open(sys.argv[1]))
env = Environment(loader=FileSystemLoader('.'), autoescape=True)
template = env.get_template(sys.argv[2])
converted = template.render(variables)

with open(sys.argv[3], "w") as output:
    sys.stdout = output
    print(converted)
