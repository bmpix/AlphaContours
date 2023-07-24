import os
import sys
import time
import subprocess
from sys import platform

print("Currently in test_script.py")

start = time.time()

fullname = sys.argv[1]
dirname = os.path.dirname(fullname)
filename = os.path.basename(fullname)
name = filename.split('.')[0]
print("Input: " + fullname)

print("Current working directory: {0}".format(os.getcwd()))
os.chdir('strokeaggregator')
print("Current working directory: {0}".format(os.getcwd()))

print("Before run_aggregator call")
os.system("run_aggregator.py ../" + fullname)
print("After run_aggregator call")

os.chdir('../strokestrip')
print("Current working directory: {0}".format(os.getcwd()))

print("Before strokestrip call")
arg2 = "..\\" + dirname + "\\" + name + "_SA_cluster.scap"
arg3 = "--widths"

if platform == "linux" or platform == "linux2" or platform == "darwin":
    # linux or mac
    subprocess.call([r"wine64 ./strokestrip.exe", arg2, arg3])
elif platform == "win32":
    # Windows...
    subprocess.call([r".\strokestrip.exe", arg2, arg3])

print("After strokestrip call")

os.chdir('../')
print("Current working directory: {0}".format(os.getcwd()))

# rename output to tmp.svg
old_name = dirname + "\\" + name + "_SA_cluster_fit.svg"
new_name = dirname + "\\tmp.svg"
os.replace(old_name, new_name)

# call matlab script
print("Before matlab call")
import matlab.engine
eng = matlab.engine.start_matlab()
eng.strips2mesh(nargout=0)
#####os.system("./strokestrip.exe ../input/" + name + "_SA_cluster.scap --widths")
print("After matlab call")

# rename output of matlab script
old_name = dirname + "\\tmp.obj"
new_name = dirname + "\\" + name + "_clusterstrips.obj"
os.replace(old_name, new_name)

end = time.time()
print("Elapsed time: " + str(end - start) + " seconds")
print("Output: " "inputs/" + name + "_clusterstrips.obj")