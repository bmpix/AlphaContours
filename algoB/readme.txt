Install python 3.9 (the version is important. Once it's installed, make sure you are able to use a command that invokes that version of python. To do so, run the "python" command in powershell and check version.)
Install svgpathtools (python module) : 
	>> pip install svgpaththools
Install matlab engine : follow these instructions https://www.mathworks.com/help/matlab/matlab_external/install-the-matlab-engine-for-python.html
	For me, (I have matlab2022a) it only worked when installing from the MATLAB folder with 
	>> cd "matlabroot\extern\engines\python"
	>> python -m pip install .

In Powershell, go to the root of algo B folder.
Your examples can go in the "inputs/" folder (.svg, didnt test with .scap). 
	Note that at the moment, outputs from strokeaggregator (that are not deleted), and the final output of the script (.obj file) also end up in the same folder as your input. (TODO? add "outputs/" folder)
Still in the root folder, run the following command to produce the output of algo B (strokes in .svg -> stroke aggregator -> stroke strip -> merge strips -> triangulate -> .obj)
Example:
	>> python algoB inputs/bear.svg

if an example ends with _new.svg, it was manually modified to remove the background rectangle from the original svg file. Otherwise SA svg parser crashes.

Examples where the script works:
bear.svg
BowTie.svg
Koala.svg
Pig02_new.svg

Examples where the script doesnt work:
AYVvm_sm.png.svg : the output of strokestrip = no strips at all ...
Flower.svg : strokestrip doesnt output the "_fit.svg" file.
Penguin_new.svg : strokestrip doesnt output the "_fit.svg" file.
Shark_new.svg : strokestrip doesnt output the "_fit.svg" file.

not tested:
12345_new.svg
Bunny01_new.svg
Bunny02_new.svg
fish_new.svg
Giraffe_new.svg
Toucan_new.svg
Triceratops_new.svg