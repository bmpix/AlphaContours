function [curvesFilename,boundaryCurve] = exportToCpp(mesh_dir,filename)
fullFilename = strcat(mesh_dir,filename,'.m');
run(fullFilename);
if nargin==4
    boundaryCurve = boundaryCurve(1:nCurves);
    openCurve = openCurve(1:nCurves);
end
[boundaryCurve,~] = mergeCurvesSharingEndpoints(boundaryCurve,openCurve);
boundaryCurve = splitSharpAngles(boundaryCurve);
[boundaryCurve,~] = split_self_intersections(boundaryCurve);

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
[~,maxEdgeLength] = averageDistance(boundaryCurve);
[xmin, xmax, ymin, ymax] = findBoundingBox(boundaryCurve);
bboxDiag = sqrt((xmax-xmin)^2+(ymax-ymin)^2);

%fmaps
%radius = 5; %for the teapot
%radius = 8; %for Hummingbird_11, Bear_003, daisy_dashed
%radius = 7; %for Fox_07
%radius = 10; %for Rabbit_05
%radius = 30; % for Wizard, for Witch (all inputs)
%radius = 35; %for Spider-Man (all inputs)

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

end

