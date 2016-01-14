function [nmi,ac] = checkClustering(W,NumC,ClusterLabels)
idx = spectralClustering(W,NumC);
res = bestMap(ClusterLabels,idx);
ac = length(find(ClusterLabels == res))/length(ClusterLabels);
nmi = MutualInfo(ClusterLabels,res);
end