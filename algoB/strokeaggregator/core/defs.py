import os, sys

CORE_DIR = os.path.dirname(os.path.realpath(__file__))
ASSETS_DIR = CORE_DIR + '/../assets/' 

EULA_DIR = ASSETS_DIR+'EULA.html'

EXE_DIR_WINS    =  {1: ASSETS_DIR+'exe_windows/strokeaggregator_single.exe',\
					4: ASSETS_DIR+'exe_windows/strokeaggregator_multi4.exe',\
					8: ASSETS_DIR+'exe_windows/strokeaggregator_multi8.exe'}

SLEEP_INTERVAL_SEC = 3

PROC_FILE_NAMES = ['']

VIEW_NONE   = 0
VIEW_SVG    = 1
VIEW_OUT    = 2

# Add top-level directory to the python path
py_location = os.path.abspath(os.path.join(os.path.join(os.path.realpath(__file__), os.pardir), os.pardir))
sys.path.insert(0, py_location)
