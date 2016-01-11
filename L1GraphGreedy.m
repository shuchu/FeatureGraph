function [W] = L1GraphGreedy(data,eps)
% This function calculates L1 graph from input data.
% y = Ax
%   x -- is what we are looking for, a higher dimension representation
%   y -- is each sample(or data point) of input data.
%   A -- is the transform matrix.
%   size:
%      x: (m+n-1) x 1
%      y: m x 1
%      A: m x (m+n-1)
%
% input:
%   data -- a data matrix: m x n , m -- features, n -- samples
% output:
%   W -- weight Matrix of L1 graph. nxn, Each row is coefficients.
%
%
% author: shhan@cs.stonybrook.edu
% 08/14/2015

tic;
% data
[m,n] = size(data);

%% data to be a sparse matrix
if not(issparse(data))
    data = sparse(data);
end

% parallel code for calculating sparse codes.
W = zeros(n-1,n);
%NZ = zeros(m,n);
parfor i = 1:n    
  %%construct the A
  y = data(:,i);
  A = data;
  A(:,i) = [];
  [x,~] = myNNOMP(y,A,eps);
  W(:,i) = x; %x(1:n-1);
  %NZ(:,i) = x(n:end);
end

% modify W from [n-1,n] to [n,n]
W=W';
% j > i part
U = triu(W);
% j < i part
L = tril(W,-1);

% extend the size
pad = zeros(n,1);
U = [pad U];
L = [L pad];
W = U + L;
toc;
end
