%Frame fields via BEM for sketch simplication
clear all;
close all;

%in each region, take its boundary
boundaryCurve = [];

N = 100;
run('../inputs/baobab.m')

openCurve = true(numel(b),1);
regionBoundaries{1} = [1:numel(b)];

[lengths,tangents,tangents_cmplx,normals,normals_cmplx,allTangents,next,curveSize] =  computeTangentsEtc(b,openCurve);
%%
%compute \hat{H}_{ij} and G_{ij} by numerically integrating the fundamental
%solution. Notations agree with https://web.stanford.edu/class/energy281/BoundaryElementMethod.pdf
for k=1:numel(b)
    [G{k}, H{k}, QQ{k}] = computeMatricesForARegion(lengths,tangents_cmplx,normals,normals_cmplx,next,b,k,curveSize,openCurve);
end

%those QQ matrices should be like little laplacians

%% plot all
figure
hold on
axis equal
axis off
set(gca, 'YDir','reverse')
for i=1:numel(b)
    plot(b{i}(:,1),b{i}(:,2))
end

%%
x = []; y = [];
for i=1:numel(b)
    x = [x; b{i}(:,1)];
    y = [y; b{i}(:,2)];
end

a = alphaShape(x,y,5)
plot(a)