#!/usr/bin/env python

import sys, math, scapio, os
from collections import defaultdict

if len(sys.argv)<2:
    print("USAGE: convertScapToMatlab.py scap_filename")
    exit(1)

f = open(sys.argv[1],'r')
fOut = open(os.path.splitext(sys.argv[1])[0]+'.m','w+')
capture,width,height = scapio.read_scap(f.read())

clusters = defaultdict(list)

for stroke in capture:
    fOut.write('b{'+str(stroke.stroke_ind+1)+'}=[')
    for p in stroke:
        fOut.write(str(p[0])+','+str(p[1])+';')
    fOut.write('];\n')
    clusters[stroke.group_ind].append(stroke.stroke_ind+1)
    fOut.write('clusterIdx('+str(stroke.stroke_ind+1)+')='+str(stroke.group_ind+1)+';\n');

for clusterIdx,cluster in clusters.items():
    fOut.write('cluster{'+str(clusterIdx+1)+'}=[')
    for c in cluster:
        fOut.write(str(c)+',')
    fOut.write('];\n')
    
fOut.close()