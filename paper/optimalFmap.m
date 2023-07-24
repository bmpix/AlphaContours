%NOTE: for some inputs, this takes a while (e.g., spiderman). Grab some
%coffee or go for a walk.

clear; close all; %clearvars;
addpath(genpath(pwd));
addpath(genpath('../SGP21_discreteOptimization-main/'));

mesh_dir = 'input/';

filename = "Hummingbird_11"; 
%filename = "Bird"; 
%filename = 'daisy_dashed';
%filename = "Rabbit_05"; 
%filename = "Wizard_06"; 
%filename = "Fox_07"; 
%filename = "Witch_08";
%filename = "Spider_Man_07";

filename2 = strcat(filename,'2');
edgeWidth = 1.5;
shapeColor = '#8cb4f4';
contourColor = '#1c4f99';
pointSize = 15;

command = '';
if ispc
    pathToExe = "../AlphaContours/bin/AlphaContours.exe";
elseif ismac
    command = '/usr/local/bin/wine64 ';
    pathToExe = "../AlphaContours/bin/AlphaContours.exe";
end

%runs a line search over the radius for the optimal fmap
[curvesFilename,boundaryCurve] = exportToCpp(mesh_dir,filename);
[curvesFilename2,boundaryCurve2] = exportToCpp(mesh_dir,filename2);

%first run with the auto settings
ss = sprintf('%s\"%s\" %s', command, pathToExe, curvesFilename);
system(ss);
contoursFilename = strcat(mesh_dir,filename,"_curves_contours.m");
if isfile(contoursFilename)
    run(contoursFilename);
    radiusOrig = radius;
    Emin = inf;
    radius_best = 0;
    rE = [];
    
    for radius=floor(radiusOrig*0.9):ceil(radiusOrig*2)
        E = meshAndFmap(command,pathToExe,mesh_dir,filename,filename2,curvesFilename,curvesFilename2,boundaryCurve,boundaryCurve2,edgeWidth,shapeColor,contourColor,pointSize,radius,true);
        rE = [rE; radius, E];
        if E < Emin
            Emin = E;
            radius_best = radius;
        end
    end

    fprintf('Found best radius: %f\n',radius_best);
    meshAndFmap(command,pathToExe,mesh_dir,filename,filename2,curvesFilename,curvesFilename2,boundaryCurve,boundaryCurve2,edgeWidth,shapeColor,contourColor,pointSize,radius_best,false);
else
    error('Alpha Contours crashes with the auto radius computation, cant proceed');
end
