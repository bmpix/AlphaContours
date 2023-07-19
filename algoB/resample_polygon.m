function Q = resample_polygon(P,E,h)
%function [Q,F] = resample_polygon(P,E,h)
  % RESAMPLE_POLYGON  Sample edges of a polygon so all new edges are smaller
  % than h
  %
  % Inputs:
  %   P  #P by dim list of input points
  %   E  #E by 2 list of input edge indices into P
  %   h  upper bound on edge length
  % Outputs:
  %   Q  #Q by dim list of output points
  %   F  #F by 2 list of output edge indices into Q
  %
    
  if isempty(E)
     E = zeros(size(P,1)-1, 2);
     E(:,1) = (1:size(E,1))';
     E(:,2) = (1:size(E,1))' + 1;
  end
  %Q = P;
  p1 = P(1,:);
  Q = [p1];
  F = [];
  l = edge_lengths(P,E); % 2.5 -> 4.5
  totall = sum(l);
  nbNewEdges = ceil(totall / h);
  nbNewPts = nbNewEdges + 1;
  
  curl = 0;
  for i = 2:nbNewPts-1
    curl = ((i-1)/nbNewEdges) * totall; % 4
    tmpl = 0; % 0 -> 2.5 -> 7 -> ...
    for j = 1:size(l,1)
        tmpl = tmpl + l(j);
        if tmpl >= curl
           howFarOnEdge = l(j) - (tmpl - curl);
           u = (P(j+1,:) - P(j,:));
           u = u/norm(u);
           newp = P(j,:) + u * howFarOnEdge;
           Q = [Q;newp];
           %disp(num2str(norm(Q(end,:) - Q(end - 1,:))));
           break; 
        end
    end
  end
  Q = [Q;P(end,:)];
  return;
end

function l = edge_lengths(P,E)
    l = zeros(size(E,1),1);
    for i = 1:size(E,1)
        l(i) = norm(P(E(i,2),:) - P(E(i,1),:));
    end
end
