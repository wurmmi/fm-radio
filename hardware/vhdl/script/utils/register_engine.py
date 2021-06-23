#!/usr/bin/env python2
# ------------------------------------------------------------------------------
#
# Author:    Johannes Walter <johannes@wltr.io>
#            Michael Wurm <wurm.michael95@gmail.com>
# Copyright: 2017-2021 Michael Wurm
# Brief:     Super Easy Register Scripting Engine (SERSE)
#
# ------------------------------------------------------------------------------

import argparse
import copy
import sys

import jinja2
import numpy
import yaml


def to_hex(value):
    return hex(int(value))[2:].upper()


def to_hex32(value):
    return 'x"' + to_hex(value).zfill(8) + '"'


def to_bin(value, length):
    return bin(int(value))[2:].zfill(length)


def to_mask(width):
    return hex(int(width * '1', 2))[2:].upper()


def to_pretty(name):
    return name.replace(' ', '_').lower()


def get_register(data, name):
    return next((x for x in data if x['name'] == name), None)


def removekey(d, key):
    r = dict(d)
    del r[key]
    return r


def replace_register(reg, n, p='[n]'):
    reg['name'] = reg['name'].replace(p, str(n))
    reg['description'] = reg['description'].replace(p, str(n))
    if 'strobe' in reg:
        reg['strobe'] = reg['strobe'].replace(p, str(n))
    for fld in reg['fields']:
        fld['name'] = fld['name'].replace(p, str(n))
        fld['description'] = fld['description'].replace(p, str(n))
        fld['connect'] = fld['connect'].replace(p, str(n))


def generate_register_data(data):
    data['original'] = copy.deepcopy(data['registers'])

    # Create full names
    for reg in data['original']:
        reg['full'] = to_pretty(data['prefix'] + '_' + reg['name'])

    # Create list of registers
    data['map'] = []
    for reg in data['original']:
        # Unroll array
        if 'type' in reg and 'size' in reg:
            if reg['type'] == "ARRAY":
                const_added = 0
                for n in range(reg['size']):
                    tmp = copy.deepcopy(reg)
                    replace_register(tmp, n)
                    if const_added == 1:
                        tmp = removekey(tmp, 'const')
                    const_added = 1
                    data['map'].append(tmp)
        else:
            tmp = copy.deepcopy(reg)
            data['map'].append(tmp)

    # Calculate offset and fill data structure
    offset = 0
    for reg in data['map']:
        reg['full'] = to_pretty(data['prefix'] + '_' + reg['name'])
        reg['reset'] = 0
        reg['mask'] = 0
        reg['offset'] = offset
        offset += 4

        check = 32 * [0]
        width = 0
        for field in reg['fields']:
            # Generate reset value and bit mask
            reg['reset'] |= field['reset'] << field['offset']
            reg['mask'] |= (2**field['width'] - 1) << field['offset']
            width += field['width']

            # Check if register name matches a connection name
            if get_register(data['map'], field['connect']):
                field['connect'] = data['prefix'] + '_' + field['connect']

            # Check connections and overlapping bit fields
            part = check[field['offset']:field['offset'] + field['width']]
            if part == int(field['width']) * [0]:
                check[field['offset']:field['offset'] + field['width']] = \
                    int(field['width']) * [1]
            else:
                print >> sys.stderr, 'ERROR: Bit fields in register ' + \
                    reg['name'] + ' are overlapping.'
                return False

        reg['width'] = width

    # Calculate needed address width
    offset -= 4
    if offset > 0:
        addr_width = int(numpy.ceil(numpy.log2(offset))) + 1

    # NOTE: AXI-lite must be at least 12 bit wide!
    #       The smallest address range that can be set in the Vivado
    #       block diagram 'Address Editor' is 4K (2^12 = 4096)
    addr_width = max(addr_width, 12)

    data['addr_width'] = addr_width
    data['addr_max'] = offset

    return True


def load_template(template):
    try:
        return jinja2_env.get_template(template)
    except:
        print >> sys.stderr, 'ERROR: Could not open template file "' + \
            args.tmpl + '".'


def write_file(filename, content):
    try:
        fp = open(filename, 'w')
        fp.write(content)
        fp.close()
    except:
        print >> sys.stderr, 'ERROR: Could not create/write file "' + \
            filename + '".'
        sys.exit(1)


if __name__ == '__main__':
    # Parser for command line arguments
    parser = argparse.ArgumentParser(description='Generates IP register files.')
    parser.add_argument('spec', help='The .yaml specification file of this IP.')
    parser.add_argument('tmpl', help='This template is used.')
    parser.add_argument('dest', help='Filename of generated file.')
    args = parser.parse_args()

    # Jinja2 for generating files out of a template file
    jinja2_env = jinja2.Environment(loader=jinja2.FileSystemLoader('.'),
                                    trim_blocks=True,
                                    lstrip_blocks=True,
                                    extensions=['jinja2.ext.do'])
    jinja2_env.filters['hex'] = to_hex
    jinja2_env.filters['hex32'] = to_hex32
    jinja2_env.filters['bin'] = to_bin
    jinja2_env.filters['mask'] = to_mask
    jinja2_env.filters['pretty'] = to_pretty

    try:
        fp = open(args.spec)
        data = yaml.load(fp, Loader=yaml.FullLoader)
        if generate_register_data(data):
            template = load_template(args.tmpl)
            content = template.render(data)
            write_file(args.dest, content)
        else:
            print >> sys.stderr, 'ERROR: Could not generate register data.'
            sys.exit(1)
    except IOError:
        print >> sys.stderr, 'ERROR: Could not open specification file "' + \
            args.spec + '".'
        sys.exit(1)
