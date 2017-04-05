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

rows = Dataset().load(open('output.csv').read(), headers=False)
rows.headers = [
    'day',
    'date',
    'begin',
    'end',
    'person_1',
    'person_2',
    'extra_begin',
    'extra_end',
    'extra_what',
    'extra_person',
    'extra_participants',
    'attention',
    'needs_substitute'
]

print template.render({'rows': rows.dict })
