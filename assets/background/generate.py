#!/usr/bin/env python
# Generate the background file

from settings import *
from string import Template
from json import loads as load_json
from os import getenv, chdir, path
from sys import argv
from random import seed as set_seed
from random import randrange as rand
import subprocess

# Goto the correct directory
chdir(path.dirname(path.realpath(argv[0])))

def read_file(file):
    text_file = open(file, "r")
    data = text_file.read()
    text_file.close()
    return data

def read_template(file):
    return Template(read_file(file))

def read_colors():
    return load_json(read_file(getenv("HOME")+"/.cache/wal/colors.json"))

def read_color_value(ids, colors):
    ids = ids.split("+")
    result = 0
    for i in ids:
        result += int(colors['color'+i][1:], 16)
    return '#{:06x}'.format(int(result/len(ids)))

def read_color_order(idx, order, colors):
    return {
        'nr': idx,
        'frame': read_color_value(order[0], colors),
        'slide': read_color_value(order[1], colors),
        'indent': read_color_value(order[2], colors),
        'bar': read_color_value(order[3], colors)
    }

def create_colors(orders, colors):
    return [read_color_order(n, o, colors) for n, o in enumerate(orders)]

# Set the seed
set_seed(seed)

main['size_x'] = 110 + main['margin'] * 2
main['size_y'] = 110 + main['margin'] * 2

colors_data = read_colors()
colors_orders = create_colors(colors, colors_data['colors'])

colors_template = read_template("template_colors.txt")
colors_output = '\n'.join(colors_template.substitute(**cs) for cs in colors_orders)

items_data = []
for x in range(main['nx']):
    for y in range(main['ny']):
        items_data.append({
            'colors':  rand(0, len(colors_orders)),
            'scale': main['scale'],
            'x': main['size_x'] * x + main['margin'],
            'y': main['size_y'] * y + main['margin']
        })

item_template = read_template("template_item.txt")
item_output = '\n'.join(item_template.substitute(**it) for it in items_data)
item_width = main['size_x'] * main['scale'] * main['nx'] / 2
item_height = main['size_y'] * main['scale'] * main['ny'] / 2

main_template = read_template("template_main.txt")
main_output = main_template.substitute(
    background=colors_data['special']['background'],
    colors=colors_output,
    items=item_output,
    width=main['width'],
    height=main['height'],
    translate='{}, {}'.format(main['transform_x'] + main['width'] / 2 - item_width, main['transform_y'] + main['height'] / 2 - item_height),
    rotate='{}, {}, {}'.format(main['angle'], item_width, item_height)
    )

f = open("background.svg", "w")
f.write(main_output)
f.close()

subprocess.run(["convert", "background.svg", "background.jpg"])
