function [cppContour,cppContourInner,boundaryCurve,seedPts,radius,pgon] = contour_cpp(mesh_dir,filename,quiet,alpha)
%normally alpha is not passed, then it is computed automatically
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
    pathToExe = "../AlphaContours/bin/AlphaContours.exe";
elseif ismac
    command = '/usr/local/bin/wine64 ';
    pathToExe = "../AlphaContours/bin/AlphaContours.exe";
end

if (nargin <= 3)
    ss = sprintf('%s\"%s\" %s', command, pathToExe, curvesFilename)
else
    radius = alpha;
    ss = sprintf('%s\"%s\" %s %f', command, pathToExe, curvesFilename, alpha)
end

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