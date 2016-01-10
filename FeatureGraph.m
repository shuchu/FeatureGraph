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
G = zeros(M,M);

for id=1:M
idx = zeros(M-1,1); 
idx(1:id-1) = 1:id-1;
idx(id:end) = id+1:M;
y = X(id,:)';
A = X(idx,:)';
[x] = OMP(A,y,th);

%% put data back to G 
%% let Column be one record
G(1:id-1,id) = x(1:id-1);
G(id+1:end,id) = x(id:end);
end

end
