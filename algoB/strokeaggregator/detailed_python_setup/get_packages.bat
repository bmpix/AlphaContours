@echo off

REM Set path
setlocal
SET PATH=C:\Python35-32\Scripts\;C:\Python35-32\;%PATH%

REM Install packages assuming the user has installed pip with the Python installer
pip3 install --user svgpathtools
pip3 install --user svgwrite

REM Since we have no idea about the platform, may just try both...
curl -L -o PyQt4-4.11.4-cp35-cp35m-win32.whl "https://download.lfd.uci.edu/pythonlibs/o4uhg4xd/PyQt4-4.11.4-cp35-cp35m-win32.whl"
pip3 install --user PyQt4-4.11.4-cp35-cp35m-win32.whl
curl -L -o PyQt4-4.11.4-cp35-cp35m-win_amd64.whl "https://download.lfd.uci.edu/pythonlibs/o4uhg4xd/PyQt4-4.11.4-cp35-cp35m-win_amd64.whl"
pip3 install --user PyQt4-4.11.4-cp35-cp35m-win_amd64.whl

REM Clean up
rm PyQt4-4.11.4-cp35-cp35m-win32.whl
rm PyQt4-4.11.4-cp35-cp35m-win_amd64.whl

pause
exit