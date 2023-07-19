#!/usr/bin/env python

import sys, re, math

class Stroke:
	def __init__(self, stroke_str = None, thickness = 1):
		self.stroke_ind = -1
		self.group_ind = -1
		self.points = []
		self.thickness = thickness

		if stroke_str == None:
			return

		stroke_str = stroke_str.replace('{', '').replace('}', '')

		# First, try reading indices
		ind_str = re.search('#.+\n', stroke_str)

		if ind_str != None:
			ind_str = ind_str.group(0)
			# delete this line
			stroke_str = stroke_str.replace(ind_str, '')

			ind_str = ind_str.replace('#', '')
			ind_str = ind_str.split('\t')
			self.stroke_ind = int(ind_str[0])
			self.group_ind = int(ind_str[1])

		# Then, read points
		s_str = stroke_str.split('\n')
		for p_str in s_str:
			if '\t' in p_str and '@' not in p_str:
				point = p_str.split('\t')
				point = [p for p in point if p != '']
				if len(point) == 0:
					continue
				self.points.append((float(point[0]), float(point[1]), int(point[2])))
			if '@' in p_str:
				p_str = p_str.replace('@', '')
				self.thickness = float(p_str)

	def length(self):
		l = 0
		for i in range(len(self.points) - 1):
			l += math.sqrt((self.points[i + 1][0] - self.points[i][0])**2 + (self.points[i + 1][1] - self.points[i][1])**2)
		return l
		
	def __repr__(self):
		scap_str = '{\n'
		scap_str += '\t#%d\t%d\n' % (self.stroke_ind, self.group_ind)
		for p in self.points:
			scap_str += '\t%f\t%f\t%d\n' % (p[0], p[1], p[2])
		scap_str += '}'

		return scap_str

	__str__ = __repr__

	def __getitem__(self, key):
		return self.points[key]

	def __setitem__(self, key, value):
		self.points[key] = value

	def append(self, value):
		self.points.append(value)

	def __len__(self):
		return len(self.points)

def fit_capture(capture):
	transformed_capture = []
	bbox = [(float('inf'), float('inf')), (-float('inf'), -float('inf'))]

	for stroke in capture:
		for point in stroke:
			bbox[0] = (min(bbox[0][0], point[0]), min(bbox[0][1], point[1]))
			bbox[1] = (max(bbox[1][0], point[0]), max(bbox[1][1], point[1]))
	for stroke in capture:
		transformed_capture.append(Stroke(thickness = stroke.thickness))
		transformed_capture[-1].stroke_ind = stroke.stroke_ind
		transformed_capture[-1].group_ind = stroke.group_ind

		for point in stroke:
			transformed_capture[-1].append((point[0] - bbox[0][0], \
				# math.ceil(bbox[1][1] - bbox[0][1]) - \
				(point[1] - bbox[0][1]), 0))
			
	return (math.ceil(bbox[1][0] - bbox[0][0]), math.ceil(bbox[1][1] - bbox[0][1]), transformed_capture)
        
def read_scap(scap_str):
	capture = []
	width = -1
	height = -1

	# First, try reading thickness
	thickness_str = re.search('@.+\n', scap_str)
	thickness = 1
	if thickness_str != None:
		thickness_str = thickness_str.group(0)
		thickness_str = thickness_str.replace('@', '')
		thickness = float(thickness_str)

	# read size
	size_str = re.match('#.+\n', scap_str)
	if size_str != None:
		size_str = size_str.group(0)
		size_str = size_str.replace('#', '')
		size_str = size_str.split('\t')
		width = int(size_str[0])
		height = int(size_str[1])

	stroke_strs = re.findall('{.+?}', scap_str, re.DOTALL)
	
	for s_str in stroke_strs:
		s = Stroke(s_str, thickness)
		capture.append(s)

	if width <= 0 or height <= 0:
		(width, height, capture) = fit_capture(capture)

	return capture, width, height

def scap_to_string(capture, width=-1, height=-1):
	if width <= 0 or height <= 0:
		(width, height, capture) = fit_capture(capture)
	scap_str = '#%d\t%d\n' % (width, height)

	if len(capture) > 0:
		scap_str += '@%d\n' % capture[0].thickness
	else:
		scap_str += '@1\n'
	
	for stroke in capture:
		scap_str += str(stroke) + '\n'

	return scap_str
