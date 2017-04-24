function [H] = SC(fea,k)
%% spectral clustering
%   	W -- similarity matrix,  
%	k -- number of eigenvectors

% calculate Gaussian Similarity Graph
tmpD = EuDist2(fea);
t = mean(mean(tmpD));
G = exp(-tmpD/(2*t^2));
G = max(G,G');

%check 1
%G(1:5,1:5)
%s = sum(G);
%find(s <= 0.00001)


% calculate Eigen vectors
Y = Eigenmap(G,k,1);

% kmeans clustering
Y = NormalizeFea(Y,1);

H = litekmeans(Y,k,'Replicates',20);
end
