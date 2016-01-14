function [IDX,egs,evecs] = spectralClustering(W,k)
% Spectral Clustering algorithm. 
%
% input: 
%   W -- similarity matrix
%   k -- number of clsuters
% ouput:
%   h -- numbers


D = sum(W,2);
D = D.^(-1/2);
D(~isfinite(D)) = 0;
D = diag(D);
L =  D * W * D;
opts.tol = 1e-3;
[evecs,egs] = eigs(sparse(L),k,'lr',opts);
%[egss,ids] = sort(diag(egs),'descend');
%[~,ids] = sort(diag(egs),'descend');
%figure, plot(egss(1:k),'-*');
%evecs = evecs(:,1:end); 
evecs = NMRow(evecs); 
IDX = kmeans(evecs,k,'start','uniform','emptyaction','singleton');
%[ctrs,~,~] = WCSSKmeans(evecs,k,50,50);
%IDX = findlabels(ctrs,evecs);
end
