function [G] = FeatureGraph(X,th)
% Calculate the feature graph from given high dimensional data;
% 
% Algorithms:
%   1, normalize features;
%   2, generate the graph using OMP solver.
% 
% Input: 
%    X -- the data matrix, col: feature, row: sample
%    th -- threshold to stop the OMP. make sure it's float type!!!
%
% Output:
%    G -- the sparse graph, each Row records the sparse coefficients.
%
%
%  Mon Jan  4 10:18:04 EST 2016
tic;
[~,M] = size(X); %% M: #features; N: #samples

%% build the sparse graph
%param.L = 10;
param.eps = min(0.1,th);
param.numThreads=-1;
W = zeros(M-1,M);
parfor id=1:M
idx = zeros(M-1,1); 
idx(1:id-1) = 1:id-1;
idx(id:end) = id+1:M;
y = X(:,id);
D = X(:,idx);
[x,~] = mexOMP(y,D,param);
W(:,id) = x;
end
% modify W from [n-1,n] to [n,n]
W=W';
% j > i part
U = triu(W);
% j < i part
L = tril(W,-1);

% extend the size
pad = zeros(M,1);
U = [pad U];
L = [L pad];
G = U + L;
toc;
end
