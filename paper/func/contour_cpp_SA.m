% clear; close all; %clearvars;
% addpath(genpath(pwd));
% addpath(genpath('../SGP21_discreteOptimization-main/'));

%mesh_dir = './input/';
%filename = 'baobab_input'; %works
%filename = 'bear'; %works
%filename = 'BowTie'; %works
%filename = 'bunny'; %works 
%filename = 'e12345'; %works
%filename = 'eye_input'; %works
%filename = 'fish'; %crashes
%filename = 'Flower'; %works
%filename = 'Giraffe'; %works
%filename = 'hand'; %works
%filename = 'Koala'; %dead inside
%filename = 'omega'; %works
%filename = 'Penguin'; %works
%filename = 'Pig01'; %works
%filename = 'Pig02'; %works
%filename = 'Shark'; %works
%filename = 'Toucan'; %works
%filename = 'Triceratops'; %works
%filename = 'tulip'; %works

% mesh_dir = './InputFromBenchmarkDataset/';
% filename = 'Art_freeform_AG_02_norm_rough';

% fullFilename = strcat(mesh_dir,filename,'.m');
% run(fullFilename);
[boundaryCurve,openCurve] = mergeCurvesSharingEndpoints(boundaryCurve,openCurve);
boundaryCurve = splitSharpAngles(boundaryCurve);
[boundaryCurve,gapSegments] = split_self_intersections(boundaryCurve);

% resample boundary curves
setResampleDistance(4);
for k = 1:size(boundaryCurve,2)
   boundaryCurve{k} = resample_polygon(boundaryCurve{k},[],getResampleDistance);
   sampleDistance = getResampleDistance/2;
   while size(boundaryCurve{k},1) <= 2
       boundaryCurve{k} = resample_polygon(boundaryCurve{k},[],sampleDistance);
       sampleDistance = sampleDistance/2;
   end    
end

% decide on a fixed radius
radius = 2*averageDistance(boundaryCurve);

%% run cpp

%% export to cpp
curvesFilename = strcat(mesh_dir,filename,'_curves.m');
f = fopen(curvesFilename,'w');
fprintf(f, "nCurves\n%d\n", numel(boundaryCurve));
for i=1:numel(boundaryCurve)
    fprintf(f, 'curve%d\n',i);
    n = size(boundaryCurve{i},1);
    fprintf(f, '%d\n',n);
    for j=1:n
        fprintf(f,"%f %f",boundaryCurve{i}(j,1),boundaryCurve{i}(j,2));
        if (j~=n)
            fprintf(f," ");
        end
    end
    fprintf(f,"\n");
end
fclose(f);


command = '';
if ispc
    pathToExe = "../cpp/bin/AlphaContours.exe";
elseif ismac
    pathToExe = "../cpp/bin/AlphaContours";
    %command = 'wine64 ';
    %pathToExe = "../cpp/bin/AlphaContours.exe";
end

ss = sprintf('%s\"%s\" %s %f', command, pathToExe, curvesFilename, radius);
system(sprintf('%s\"%s\" %s %f', command, pathToExe, curvesFilename, radius));
tic
run(strcat(mesh_dir,filename,"_curves_contours.m"));
toc

%%
figure
axis equal
%axis off
hold on
for i=1:numel(boundaryCurve)
    plot(boundaryCurve{i}(:,1),-boundaryCurve{i}(:,2),'LineWidth',2);
end
%%
count = 1;
for i=1:numel(cppContour)
    polyX{count} = cppContour{i}(:,1);
    polyY{count} = -cppContour{i}(:,2);
    plot(cppContour{i}(:,1),-cppContour{i}(:,2),'LineWidth',2,'Color',[0 0 0]);
    count = count + 1;
end
if (exist('cppContourInner','var'))
    for i=1:numel(cppContourInner)
        polyX{count} = cppContourInner{i}(:,1);
        polyY{count} = -cppContourInner{i}(:,2);
        plot(cppContourInner{i}(:,1),-cppContourInner{i}(:,2),'LineWidth',2,'Color',[0 0 0]);
        count = count + 1;
    end
end
pgon = polyshape(polyX,polyY);
plot(pgon)
return;
%%
%all segments from endpoints
run(strcat(mesh_dir,filename,"_curves_segments.m"));
%plot([segmentsStart(:,1)'; segmentsEnd(:,1)'],-[segmentsStart(:,2)';segmentsEnd(:,2)'],'Color',[0.5,0.5,0.5]);
%plot([segmentsStart(:,1)'; segmentsEnd(:,1)'],-[segmentsStart(:,2)';segmentsEnd(:,2)'],'Color','r');
vec = segmentsEnd-segmentsStart;
h = quiver(segmentsStart(:,1),-segmentsStart(:,2),vec(:,1),-vec(:,2),0,'Color',[0.5,0.5,0.5]);
%run(strcat(mesh_dir,filename,"_curves_segments_minmax.m"));
%vec = segmentsEnd-segmentsStart;
%h = quiver(segmentsStart(:,1),-segmentsStart(:,2),vec(:,1),-vec(:,2),0,'Color','r');