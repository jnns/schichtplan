# -*- coding: utf-8 -*-
from tablib import Dataset
from jinja2 import Environment, FileSystemLoader

import sys

reload(sys)
sys.setdefaultencoding('utf8')

env = Environment(
    trim_blocks=True,
    loader=FileSystemLoader('.'),
)

template = env.get_template('template.html')
rows = Dataset().load(open('output.csv').read(), headers=True)
print template.render({'rows': rows.dict})
