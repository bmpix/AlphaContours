#!/usr/bin/env python

import sys, os, re, math

# Add top-level directory to the python path
py_location = os.path.abspath(os.path.join(os.path.join(os.path.realpath(__file__), os.pardir), os.pardir))
sys.path.insert(0, py_location)

import core.scapio as scapio
import core.transfer_scap as transfer_scap

read_scap = scapio.read_scap
rotate_capture = transfer_scap.rotate_capture
reflect_capture = transfer_scap.reflect_capture

try:
	import svgwrite
except ImportError:
	sys.path.insert(0, os.path.abspath(os.path.split(os.path.abspath(__file__))[0]+'/..'))

import svgwrite
if svgwrite.version < (1,0,1):
	print("This script requires svgwrite 1.0.1 or newer for internal stylesheets.")
	sys.exit()

infile = '-'
outfile = '-'
to_fit_size = False
to_viz_cut = False
is_closure = False
is_mls = False
board_size = (-1, -1)
CSS_STYLES = """
	.background { fill: white; }
	.line { stroke: firebrick; stroke-width: .1mm; }
	.blacksquare { fill: indigo; }
	.whitesquare { fill: white; }
"""
to_color = False

# A palette with optimally distinct colors
# http://tools.medialab.sciences-po.fr/iwanthue/
palette = ['#c583d9', '#9de993', '#ad5ba7', '#58f2c3', '#c94e76', \
'#57b870', '#d271bb', '#3d8e43', '#f375a0', '#00d4db', '#d55969', \
'#64e4ff', '#e68e54', '#54aeff', '#eed973', '#008bd4', '#fdb968', \
'#6f73bc', '#bee481', '#8f6aaf', '#8bb658', '#bbabff', '#658424', \
'#f1b9ff', '#989c37', '#bb568c', '#cfe395', '#c45372', '#008c6f', \
'#ff94af', '#488656', '#ffc0e1', '#6c8139', '#a9d0ff', '#a98c2c', \
'#0294bb', '#d7b555', '#4a7ea6', '#ffa372', '#96ddff', '#b06735', \
'#bae0f9', '#b76246', '#b0e4e9', '#ff9b9c', '#378673', '#ffa98e', \
'#6a79a2', '#ffcca9', '#53827e', '#ffcdcf', '#648168', '#e7d3fa', \
'#93744c', '#cde1bc', '#9b6a8a', '#efd8b1', '#928098', '#7c7b5c', '#a6686c']

def eprint(args):
	sys.stderr.write(args + '\n')

def draw_capture(capture, dwg):
	global to_color, palette, to_viz_cut

	out_s_width = 0.5

	for stroke in capture:
		d_str = ''
		s_width = out_s_width
		for point in stroke:
			control_str = ' L '
			if d_str == '':
				control_str = 'M '
			d_str += control_str + '%f %f' % (point[0], point[1])
		color_str = 'black'
		s_width = stroke.thickness

		if to_color:
			color_str = palette[stroke.group_ind % len(palette)]

			if is_closure and stroke.group_ind == 0:
				color_str = '#000000'

			s_width = out_s_width

		#print(d_str)

		dwg.add(dwg.path(d=d_str, fill='none', stroke=color_str, stroke_width=s_width))
		#dwg.save()

		if to_viz_cut and len(stroke) > 0:
			dwg.add(dwg.circle(center=(stroke[0][0], stroke[0][1]), r='1px', fill='red', stroke='none', stroke_width=0))
			dwg.add(dwg.circle(center=(stroke[-1][0], stroke[-1][1]), r='1px', fill='red', stroke='none', stroke_width=0))

def draw_mls(capture, dwg):
	out_radius = 2
	out_line_w = 1

	dots = []
	lines = []

	for stroke in capture:
		if stroke.stroke_ind == -2:
			dots.append(stroke)
		elif stroke.stroke_ind == -4:
			lines.append(stroke)

	# we want dots on top of lines
	for stroke in lines:
		start = (stroke[0][0], stroke[0][1])
		end = (stroke[1][0], stroke[1][1])
		s_width = out_line_w
		color_str = 'gray'
		dwg.add(dwg.line(start=start, end=end, fill='none', stroke=color_str, stroke_width=s_width))

	for stroke in dots:
		center = (stroke[0][0], stroke[0][1])
		s_width = out_radius
		color_str = 'green'

		dwg.add(dwg.circle(center=center, r=s_width, fill=color_str, stroke=color_str, stroke_width=s_width))


def parse_args():
	global infile, outfile, board_size, to_fit_size, to_viz_cut, \
	to_color, is_closure, is_mls

	for arg in sys.argv:
		if '.scap' in arg:
			infile = arg
		elif '.svg' in arg:
			outfile = arg
		elif '-f' == arg:
			to_fit_size = True
		elif '-c' == arg:
			to_color = True
		elif '-v' == arg:
			to_viz_cut = True
		elif '-l' == arg:
			is_closure = True
		elif '-m' == arg:
			is_mls = True
		else:
			m = re.match(r'[0-9]+x[0-9]+', arg)
			
			if m != None:
				size_str = m.group(0)
				board_size = (int(size_str.split('x')[0]), int(size_str.split('x')[1]))

	if outfile == '-':
		sys.exit("Usage:\n\tscap-to-svg.py [-f|-c] [infile.scap] [outfile.svg]\nTo omit infile.scap and use stdio, replace file name with '-'")

def to_svg(infile, outname):
	global board_size, to_fit_size, \
	is_closure, is_mls

	capture, width, height = read_scap(infile.read())

	if board_size[0] >= 0 and board_size[1] >= 0:
		width = board_size[0]
		height = board_size[1]
	elif to_fit_size:
		(width, height, capture) = scapio.fit_capture(capture)
		thickness = 0
		for s in capture:
			thickness = max(thickness, s.thickness)

		width += thickness
		height += thickness

		transformed_capture = []
		for stroke in capture:
			transformed_capture.append(scapio.Stroke(thickness = stroke.thickness))
			transformed_capture[-1].stroke_ind = stroke.stroke_ind
			transformed_capture[-1].group_ind = stroke.group_ind

			for point in stroke:
				transformed_capture[-1].append((point[0] + thickness / 2, \
					(point[1] + thickness / 2), 0))

		capture = transformed_capture

	if is_closure:
		capture = reflect_capture(capture, 1, -1)
		capture = rotate_capture(capture, 90)
		(width, height, capture) = scapio.fit_capture(capture)

	dwg = svgwrite.Drawing(outname, size=(width, height))
	dwg.viewbox(0, 0, width, height)
	# checkerboard has a size of 10cm x 10cm;
	# defining a viewbox with the size of 80x80 means, that a length of 1
	# is 10cm/80 == 0.125cm (which is for now the famous USER UNIT)
	# but I don't have to care about it, I just draw 8x8 squares, each 10x10 USER-UNITS

	# always use css for styling
	dwg.defs.add(dwg.style(CSS_STYLES))
	
	if not is_mls:
		draw_capture(capture, dwg)
	else:
		draw_mls(capture, dwg)
	dwg.save()

if __name__== '__main__':
	parse_args()

	if infile == '-':
		eprint("Reading scap from stdin.")
		infile = sys.stdin
	else:
		eprint("Reading scap from '" + infile + "'")
		infile = open(infile, 'rt')

	assert(outfile != '-')
	eprint("Writing svg to '" + outfile + "'")

	to_svg(infile, outfile)

	if infile != sys.stdin:
		infile.close()
