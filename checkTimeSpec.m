function h = checkTimeSpec(Data, NumC, ClusterLabels)
% Check the k-means clustering performance of data using all features.
% and, check the clustering performance in Spectral domain.

D = EuDist2(Data);
Woptions.t = mean(mean(D));
Woptions.k = 5;
W = constructW(Data,Woptions);
Y = Eigenmap(W,NumC);

% clustering performance in original Data domain
disp('Data domain:');
kmeansPer(Data,ClusterLabels,NumC);

% now spectral domain.
disp('Spectral domain:');
kmeansPer(Y,ClusterLabels,NumC);

end