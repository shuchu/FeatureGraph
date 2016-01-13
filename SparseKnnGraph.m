function [G] = SparseKnnGraph(X,NB,th)
% Calculate the sparse graph from given data, with kNN constraints;
% The User needs to define the NB constraints, where NB is a data matrix define
% the indexes of Neighbors for each instance.
% 
% Algorithms:
%   1, normalize instances;
%   2, generate the graph using OMP solver.
% 
% Input: 
%    X -- MxN,the data matrix, Column means instances. X should be properly normalized. 
%    NB -- KxN,the input Neighborhood index matrix, each column record the indexes.
%    th -- threshold to stop the OMP. make sure it's float type!!! Integer type
%          means number of sparse atoms.
%
% Output:
%    G -- the sparse graph, each Column records the sparse coefficients.
%
%
%  Mon Jan  4 10:18:04 EST 2016

[M,N] = size(X);  
[K,NN] = size(NB);
G = zeros(N);
%% check size of NB
if (NN ~= N)
  return;
end
 
%% build the sparse graph
W = zeros(K,N);
for id=1:N
y = X(:,id);
A = X(:,NB(:,id));
if (K < M)
    [x] = OMP(A,y,K);
else
    [x] = OMP(A,y,th);
end
W(:,id) = x;
end
% modify W from [n-1,n] to [n,n]
G = zeros(N);
for i = 1:N
 G(NB(:,i),i) = W(:,i);
end

end
