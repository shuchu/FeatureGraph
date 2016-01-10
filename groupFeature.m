function [H] = groupFeature(data, V)
% group Features according to the K eigen vectors.
%
% input:
%   V -- (N x K), the first K eigenvectors (trivial eigenvector excluded).
%   data -- (N x M), orginal data, feature normalized. 
% output:
%   H -- (K x M) coefficients of each feature to K eigenvectors. Column
%   wise
%

[~,K] = size(V);
[~,M] = size(data);

H = zeros(K,M);

%finding sparse coefficients
for i = 1:M
[t,~] = myNNOMP(data(:,i),V,1e-5);    
H(:,i) = t;   
end


end