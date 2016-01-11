function [G] = FeatureGraph(X,th)
% Calculate the feature graph from given high dimensional data;
% 
% Algorithms:
%   1, normalize features;
%   2, generate the graph using OMP
% 
% Input: 
%    X -- the data matrix, row: feature, col: sample
%    th -- threshold to stop the OMP. make sure it's float type!!!
%
% Output:
%    G -- the sparse graph, each Column records the sparse coefficients.
%
%
%  Mon Jan  4 10:18:04 EST 2016

%% normalize the data by (1) mean of each feature equals to zero; 
%% (2) features have unit lenght;
[M,N] = size(X); %% M: #features; N: #samples
mu = mean(X,2);
X = X - mu*ones(1,N);
d = sqrt(sum(X.^2,2));
d(d==0) = 1;
X = X./(d*ones(1,N));


%% build the sparse graph
W = zeros(M-1,M);
parfor id=1:M
idx = zeros(M-1,1); 
idx(1:id-1) = 1:id-1;
idx(id:end) = id+1:M;
y = X(id,:)';
A = X(idx,:)';
if (M <= N)
  [x] = OMP(A,y,M-1);
else
  [x] = OMP(A,y,th);
end
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

end
