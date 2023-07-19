import os
import sys
import fileinput

basedir = ''
path = 'assets\\exe_windows\\strokeaggregator_single.exe'
svg_to_scap_path = 'core/svg_to_scap.py'

if len(sys.argv) < 2:
 print('run_aggregator.py file.svg: Automatically converts svg to SCAP format and then runs StrokeAggregator on that')
 sys.exit(0)
 
fullFilename = sys.argv[1]

#first, remove the pesky xlink:href namespace which makes the xml incorrect
with fileinput.FileInput(fullFilename, inplace=True) as file:
    for line in file:
        print(line.replace('xlink:href', 'href'), end='')

filename = os.path.basename(fullFilename)
scapFilename = './tmp/'+ filename + '.scap'
cmd1 = 'python '+basedir+svg_to_scap_path+' '+fullFilename+' -o '+scapFilename
print(cmd1)
os.system('python '+basedir+svg_to_scap_path+' '+fullFilename+' -o '+scapFilename)
cmd1 = basedir+path+' '+scapFilename + ' -o '+fullFilename[:-4]+'_SA.svg'
print(cmd1)
os.system(cmd1)
