% update
% 2018-05-08: set up alpha automatically
% 2018-05-06: add the orientation term into the energy
% 2018-05-23: fix the orienttion term - orientationOp per descriptors

% original file: test_commute_faust.m
% paper: Informative Descriptor Preservation via Commutativity for Shape Matching
% Input:
%   S1: the source mesh with the new basis B1, and the corresponding eigenvalues Ev1
%   S2: the target mesh with the new basis B2, and the corresponding eigenvalues Ev2
%   fct_src: the descriptors of shape S1
%   fct_tar: the descriptors of shape S2
function [C12, para2, myObj] = compute_fMap_regular_with_orientationOp_local(S1,S2,B1,B2,Ev1,Ev2,fct_src,fct_tar,type,para)
a = 1e-1; % Descriptors preservation
b = 1;    % Commutativity with descriptors
c = 1e-1; % 1e-3 Commutativity with Laplacian (cat c = 1e-1, alpha = 20
d = 0;
beta = 1;
numEigsSrc = size(B1,2); numEigsTar = size(B2,2);
if nargin < 9, type = 'direct'; end
if nargin > 9
    if isfield(para,'a'), a = para.a; end
    if isfield(para,'b'), b = para.b; end
    if isfield(para,'c'), c = para.c; end
    if isfield(para,'d'), d = para.d; end
    % alpha is set w.r.t. a
    if isfield(para,'beta'), beta = para.beta; end % 
end

%--------------------------------------------------------------------------
% Descriptors
assert(size(fct_src,2)==size(fct_tar,2));
% Normalization
no = sqrt(diag(fct_src'*S1.A*fct_src))';
fct_src = fct_src ./ repmat(no, [S1.nv,1]);
no = sqrt(diag(fct_tar'*S2.A*fct_tar))';
fct_tar = fct_tar ./ repmat(no, [S2.nv,1]);
%--------------------------------------------------------------------------
% Multiplication Operators
numFct = size(fct_src,2);
OpSrc = cell(numFct,1);
OpTar = cell(numFct,1);
for i = 1:numFct
    OpSrc{i} = B1'*S1.A*(repmat(fct_src(:,i), [1,numEigsSrc]).*B1);
    OpTar{i} = B2'*S2.A*(repmat(fct_tar(:,i), [1,numEigsTar]).*B2);
end
Fct_src = B1'*S1.A*fct_src;
Fct_tar = B2'*S2.A*fct_tar;
% Orientation-preserving Operators
compute_all_OrientationOp = @(S,B,fct) ...
    cellfun(@(f) OrientationOp(S,B,f),mat2cell(fct,size(fct,1),ones(size(fct,2),1)),'un',0);
F11_all = compute_all_OrientationOp(S1,B1,fct_src);
F22_all = compute_all_OrientationOp(S2,B2,fct_tar);
%% all energy terms and the corresponding gradient
% C: Src -> Tar
Dlb = (repmat(Ev1, [1,numEigsTar]) - repmat(Ev2', [numEigsSrc,1])).^2;
Dlb = Dlb/norm(Dlb, 'fro')^2;

% orientation term
funOrient_direct = @(C) sum(cellfun(@(F11,F22) 0.5*norm(C*F11 - F22*C, 'fro')^2,F11_all, F22_all));
gradOrient_direct = @(C) sum(cell2mat(cellfun(@(F11,F22) reshape(C*(F11*F11') - F22'*C*F11 - F22*C*F11' + F22'*F22*C,[],1),...
    F11_all, F22_all,'un',0)),2);
funOrient_symm = @(C) sum(cellfun(@(F11,F22) 0.5*norm(C*F11 + F22*C, 'fro')^2,F11_all, F22_all));
gradOrient_symm = @(C) sum(cell2mat(cellfun(@(F11,F22) reshape(C*(F11*F11') + F22'*C*F11 + F22*C*F11' + F22'*F22*C,[],1),...
    F11_all, F22_all,'un',0)),2);
% descriptors term
funDesp = @(C) 0.5*norm(C*Fct_src - Fct_tar,'fro')^2;
gradDesp = @(C) reshape((C*Fct_src - Fct_tar)*Fct_src',[],1);
% commutativity with descriptors
funCommDesp = @(C) sum(cell2mat(cellfun(@(X,Y) 0.5*norm(X*C - C*Y,'fro')^2, OpTar', OpSrc', 'UniformOutput', false)), 2);
gradCommDesp = @(C) sum(cell2mat(cellfun(@(X,Y) reshape(X'*(X*C - C*Y) - (X*C - C*Y)*Y',[],1), OpTar', OpSrc', 'UniformOutput', false)), 2);
% commutativity with LB
funCommLB = @(C) sum(sum((C.^2 .* Dlb)/2));
gradCommLB =@(C) reshape(C.*Dlb,[],1);

%% Fmap Computation
%--------------------------------------------------------------------------
constFct = sign(B1(1,1)*B2(1,1))*[sqrt(sum(S2.area)/sum(S1.area)); zeros(numEigsTar-1,1)];
F_lb = zeros(numEigsTar*numEigsSrc, 1); F_lb(1) = constFct(1);

% T21 = knnsearch(fct_src, fct_tar);
% C12 = B2\B1(T21,:);
% F_lb = C12(:);
% set up the alpha s.t. the descriptor_preservation and 
% orientation_preservation term have the same scale
% C = mat_projection(rand(numEigsTar,numEigsSrc)); % random initialization
C = eye(numEigsTar,numEigsSrc); % identity initialization


% eval_direct = @(C) norm(C*Fct_src - Fct_tar,'fro')/...
%     sum(cellfun(@(F11,F22) norm(C*F11 - F22*C, 'fro'),F11_all, F22_all));
% eval_symm = @(C) norm(C*Fct_src - Fct_tar,'fro')/...
%     sum(cellfun(@(F11,F22) norm(C*F11 + F22*C, 'fro'),F11_all, F22_all));


eval_direct = @(C) funCommDesp(C)/funOrient_direct(C);
eval_symm = @(C) funCommDesp(C)/funOrient_symm(C);

eval_direct = @(C) 1/funOrient_direct(C);
eval_symm = @(C) 1/funOrient_symm(C);


switch type
    case 'direct'
        alpha = beta*eval_direct(C);
        myObj = @(C) a*funDesp(C) + b*funCommDesp(C) + c*funCommLB(C) + alpha*funOrient_direct(C);
        myGrad = @(C) a*gradDesp(C) + b*gradCommDesp(C) + c*gradCommLB(C) + alpha*gradOrient_direct(C);
        funObj = @(F) deal(myObj(reshape(F,numEigsTar, numEigsSrc)),...
            myGrad(reshape(F,numEigsTar, numEigsSrc)));        
    case 'symmetric'
        alpha = beta*eval_symm(C);
        myObj = @(C) a*funDesp(C) + b*funCommDesp(C) + c*funCommLB(C) + alpha*funOrient_symm(C);
        myGrad = @(C) a*gradDesp(C) + b*gradCommDesp(C) + c*gradCommLB(C) + alpha*gradOrient_symm(C);
        funObj = @(F) deal(myObj(reshape(F,numEigsTar, numEigsSrc)),...
            myGrad(reshape(F,numEigsTar, numEigsSrc)));       
    otherwise
        error(['Invalid type: ',type]);
end
para2 = para; para2.alpha = alpha;

funProj = @(F) [constFct; F(numEigsTar+1:end)];
options.maxIter = 1e4;
options.verbose = 1;
fprintf('Optimizing the functional map with %s operator...',type);tic;
C12 = reshape(minConf_PQN(funObj, F_lb, funProj, options), [numEigsTar,numEigsSrc]);
t = toc; fprintf('done %.4fs.\n', t);
end
