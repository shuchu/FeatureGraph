function [W] = l1graphknn(data,lambda,K)
% L1 graph with KNN as dictionary
%
% X: n*d data matrix
% lambda 0.5*||y - A*x||^2 + lambda*||x||_1
%
% input:
%   data -- row:sample,column:feature
%   lamda -- parameter for L1 minimization
%   K -- KNN dictionary
%
% output:
%   G -- sparse graph, Directed, Weighted.
%
% requirements:
%   minmax package for finding max/min KNN
%
% author:
%   shhan@cs.stonybrook.edu
%   Tue Jan 26 17:45:24 EST 2016

warning('off','all');
%%%%%parameter set up%%%%%%%%%%%%%%%%%%%%%%%
%lambda = 0.1;
%%%%%parameter set up%%%%%%%%%%%%%%%%%%%%%%%

X = normalize(data);
[n,d] = size(X);

% build the KNN dictionary
sim = X'*X; % similarity(PCC) between features
sim(logical(eye(size(sim)))) = 0;
[~,dict] = maxk(sim,K);

Xinit = zeros(n+K,1);
talpha = zeros(n+K,d);
%matlabpool open;
for i = 1:d,
    %fprintf('process datum %d\n', i);
    A = [X(:,dict(:,i)) eye(n)];
    Y = X(:,i);
    Xout = l1ls_featuresign (A, Y, lambda/2, Xinit);
    talpha(:,i) = Xout;
end
%matlabpool close;
alpha = zeros(d);
for i = 1:d,
    alpha(dict(:,i),i) = talpha(1:K,i);
end

%W = .5*(abs(alpha)+abs(alpha'));
W = sparse(alpha);
end

