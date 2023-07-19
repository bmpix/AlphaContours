function myWriteOBJ(filename, V,F)
% WRITEOBJ writes an OBJ file with vertex/face information
%
% writeOBJ(filename,V,F,UV,N)
%
% Input:
%  filename  path to .obj file
%  V  #V by 3 list of vertices
%  F  #F by 3 list of triangle indices
%  UV  #UV by 2 list of texture coordinates
%  TF  #TF by 3 list of corner texture indices into UV
%  N  #N by 3 list of normals
%  NF  #NF by 3 list of corner normal indices into N
%
hasN =  exist('N','var') && ~isempty(N);
hasUV = exist('UV','var') && ~isempty(UV);
hasC = exist('C','var') && ~isempty(C) && isequal(size(V), size(C));


%disp(['writing: ',filename]);
f = fopen( filename, 'w' );

n = size(V,2);

for k = 1:n
    V{k} = V{k}';
    F{k} = F{k}';
end

% write all vertices
for k = 1:n
    if size(V{k},2) == 2
        warning('Appending 0s as z-coordinate');
        V{k}(:,end+1:3) = 0;
    else
        assert(size(V{k},2) == 3);
    end
    fprintf( f, 'v %0.17g %0.17g %0.17g\n', V{k}');
end

% write all faces
for k = 1:n
    inc = 0;
    for i = 1:(k-1)
       inc = inc + size(V{i}, 1); 
    end
    F{k} = F{k} + inc;
    for i = 1:size(F{k}, 1)
        fmt = repmat(' %d',1,size(F{k},2));
        fprintf( f,['f' fmt '\n'], F{k}(i,:));
    end
end

fclose(f);
end
