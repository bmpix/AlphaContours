function [cppContour,cppContourInner,boundaryCurve,seedPts,radius,pgon] = contour_cpp(mesh_dir,filename,quiet)
fullFilename = strcat(mesh_dir,filename,'.m');
run(fullFilename);
[boundaryCurve,~] = mergeCurvesSharingEndpoints(boundaryCurve,openCurve);
boundaryCurve = splitSharpAngles(boundaryCurve);
[boundaryCurve,~] = split_self_intersections(boundaryCurve);

%% resample boundary curves
setResampleDistance(4);
for k = 1:size(boundaryCurve,2)
   boundaryCurve{k} = resample_polygon(boundaryCurve{k},[],getResampleDistance);
   sampleDistance = getResampleDistance/2;
   while size(boundaryCurve{k},1) <= 2
       boundaryCurve{k} = resample_polygon(boundaryCurve{k},[],sampleDistance);
       sampleDistance = sampleDistance/2;
   end    
end


%% export to cpp
curvesFilename = strcat(mesh_dir,filename,'_curves.m');
f = fopen(curvesFilename,'w');
fprintf(f, "nCurves\n%d\n", numel(boundaryCurve));
for i=1:numel(boundaryCurve)
    fprintf(f, 'curve%d\n',i);
    n = size(boundaryCurve{i},1);
    fprintf(f, '%d\n',n);
    for j=1:n
        fprintf(f,"%.15f %.15f",boundaryCurve{i}(j,1),boundaryCurve{i}(j,2));
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
    %pathToExe = "../cpp/bin/AlphaContours";
    command = '/usr/local/bin/wine64 ';
    pathToExe = "../cpp/bin/AlphaContours.exe";
end

%% RADIUS:

% input radius value:
%ss = sprintf('%s\"%s\" %s %f', command, pathToExe, curvesFilename, radius)
%ss = sprintf('%s"%s" %s %f -j', command, pathToExe, curvesFilename, radius) 

% authomatically compute radius:
ss = sprintf('%s\"%s\" %s', command, pathToExe, curvesFilename)
%ss = sprintf('%s"%s" %s -j', command, pathToExe, curvesFilename)

%% For Fig.19, the radii for fmaps:
%radius = 13; %for Hummingbird_11
%radius = 8; %for Bird
%radius = 12; %for daisy_dashed
%radius = 10; %for Rabbit_05
%radius = 50; %for Wizard_06
%radius = 6; %for Fox_07
%radius = 46; %for Witch_08
%radius = 37; %for Spider_Man_07

% and uncomment this line:
%ss = sprintf('%s\"%s\" %s %f', command, pathToExe, curvesFilename, radius)

%% For Fig.18 (filename = 'Toucan'), uncomment one the following lines:
%radius = 6.877796268488884 % automatically computed
%radius = 6.877796268488884/2;
%radius = 6.877796268488884*2;

% and uncomment this line:
%ss = sprintf('%s\"%s\" %s %f', command, pathToExe, curvesFilename, radius)

%% 
system(ss);
run(strcat(mesh_dir,filename,"_curves_contours.m"));

%if there are no inner contours, create an empty cell array
if ~exist('cppContourInner','var')
    cppContourInner = {};
end

if quiet
    return
end
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
end