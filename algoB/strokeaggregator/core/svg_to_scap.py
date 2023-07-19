
import sys, os, re, subprocess, operator
from svgpathtools import Path, Line, QuadraticBezier, \
	CubicBezier, Arc, svg2paths, wsvg, disvg, misctools

# Add top-level directory to the python path
py_location = os.path.abspath(os.path.join(os.path.join(os.path.realpath(__file__), os.pardir), os.pardir))
sys.path.insert(0, py_location)

import core.scapio as scapio

sample_rate_mm = 2
path_filename = '-'
translation = (0, 0)
out_filename = '-'
out_scale = 1#3.5
y_flip = 1

def parse_args():
	global path_filename, sample_rate_mm, \
		translation, out_filename, out_scale, y_flip

	error = False
	for i, arg in enumerate(sys.argv):
		if '.svg' in arg and path_filename == '-':
			path_filename = arg
		elif '-o' == arg:
			if i + 1 >= len(sys.argv):
				error = True
				break
			out_filename = sys.argv[i + 1]
		elif '-r' == arg:
			if i + 1 >= len(sys.argv):
				error = True
				break
			try:
				sample_rate_mm = float(sys.argv[i + 1])
			except ValueError:
				error = True
				break

	if path_filename == '-' or error:
		sys.exit("Usage:  svg-to-scap.py [-r SAMPLE_STEP_MM] path_filename.svg -o out.svg|out.scap\n" +\
			"Program Option:\n" + "    -r         Change the path sampling step for non piecewise-linear curves to SAMPLE_STEP_MM. The default value is 2.")

def resample_path(path, sample_rate):
	resampled_path = []

	path_len = [0]
	for p in path:
		path_len.append(path_len[-1] + p.length())

	sample_len = sample_rate * path_len[-1]

	acc_sample_len = 0
	c = 0
	local_poly = None
	while acc_sample_len < path_len[-1]:
		large_ind = [ind for (l, ind) in zip(path_len, range(0, len(path_len))) if l > acc_sample_len]

		if len(large_ind) < 1:
			break

		curr_ind = large_ind[0] - 1
		next_ind = large_ind[0]

		local_t = (acc_sample_len - path_len[curr_ind]) / (path_len[next_ind] - path_len[curr_ind])

		if type(path[curr_ind]) is Arc:
			local_poly = path[curr_ind]
			resampled_path.append((local_poly.point(local_t).real, local_poly.point(local_t).imag))
		else:
			local_poly = path[curr_ind].poly()
			resampled_path.append((local_poly(local_t).real, local_poly(local_t).imag))

		acc_sample_len = acc_sample_len + sample_len
		c = c + 1

	if len(resampled_path) == 0:
		if type(path[-1]) is not Arc:
			resampled_path.append((path[0].poly()(0).real, path[0].poly()(0).imag))
		else:
			resampled_path.append((path[0].point(0).real, path[0].point(0).imag))

	if type(path[-1]) is not Arc:
		local_poly = path[-1].poly()
		resampled_path.append((local_poly(1).real, local_poly(1).imag))
	else:
		local_poly = path[-1]
		resampled_path.append((local_poly.point(1).real, local_poly.point(1).imag))

	return resampled_path

def parse_path(paths, attributes, sample_rate_mm):
	resampled_paths = []
	path_width = 1

	for i in range(0, len(paths)):
		if paths[i].length() == 0:
			continue

		is_polygonal = True
		for seg in paths[i]:
			if type(seg) is not Line:
				is_polygonal = False
				break

		path = []
		if is_polygonal:
			for seg in paths[i]:
				path.append((seg.start.real, seg.start.imag))
			if len(paths[i]) > 0:
				path.append((paths[i][-1].end.real, seg.end.imag))
		else:
			path = resample_path(paths[i], sample_rate_mm / paths[i].length())

		if 'stroke-width' in attributes[i]:
			path_width = float(attributes[i]['stroke-width'])
		else:
			path_width = 1
		resampled_paths.append(path)

	return resampled_paths, path_width

def to_scap(inname, outfile):
	global sample_rate_mm
	paths, attributes = svg2paths(inname)
	resampled_paths, path_width = parse_path(paths, attributes, sample_rate_mm)

	capture = []
	s_ind = 0
	g_ind = 0

	for path in resampled_paths:
		stroke = scapio.Stroke(thickness = path_width)
		stroke.stroke_ind = s_ind
		stroke.group_ind = g_ind

		for p in path:
			stroke.append((p[0] * out_scale, y_flip * p[1] * out_scale, 0))

		capture.append(stroke)
		s_ind = s_ind + 1

	outfile.write(scapio.scap_to_string(capture))

if __name__ == '__main__':
	parse_args()

	if out_filename == '-':
		out_filename = sys.stdout
	else:
		out_file = open(out_filename, 'w')

	to_scap(path_filename, out_file)

	if out_file != sys.stdout:
		out_file.close()

		# If the output file is empty, delete it
		if os.stat(out_filename).st_size == 0:
			os.remove(out_filename)
