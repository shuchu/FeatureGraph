function [W,NZ] = L1GraphKNN(data,nb,K,lambda)
% This function calculates the L1 graph of 'data' by selecting neigbors
% with kNN method.
% y = Ax
%   x -- is what we are looking for, a higher dimension representation
%   y -- is each sample(or data point) of input data.
%   A -- is the transform matrix.
%   size:
%      x: (m+n-1) x 1
%      y: m x 1
%      A: m x (m+n-1)
% requires:
%   knnsearch.m
% input:
%   data -- a data matrix: m x n , m -- features, n -- samples
%   nb   -- matrix of dictionary pool,
%   K    -- k nearest neighbor.
%   lambda  -- parameter for L1 solver.
% output:
%   W -- weight Matrix of L1 graph.
% comment:
%   require l1_ls solver.
% 
%
% author: shhan@cs.stonybrook.edu
% 08/15/2015

%% calculate the knn for each data point
%addpath('./knnsearch');
addpath('./l1_ls_matlab/');
tic;
%% the closest neighbor is iteself.
%[nb,~]=knnsearch(data',data',K);

% size of data
[m,n] = size(data);

% normalize data
data = NMCol(data);

%% data to be a sparse matrix
if not(issparse(data))
    data = sparse(data);
end

rel_tol = 0.00001;
quiet = true;

NZ = zeros(m,n);
WW = zeros(K,n);

parfor i = 1:n
  %%construct the A
  y = data(:,i);
  A = [data(:,nb(i,:)),speye(m)];
  [x, ~] = l1_ls_nonneg(A,y,lambda,rel_tol,quiet);
  WW(:,i) = x(1:K);
  NZ(:,i) = x(K+1:end);
end

%%parse W to adjacent matrix
% remove the noise part
W = zeros(n);
for i = 1:n
    W(nb(i,:),i) = WW(:,i);
end;
toc;
end
