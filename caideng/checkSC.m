function [nmi,ac] = checkSC(fea,NumC,ClusterLabels)
idx = SC(fea,NumC);

%tmpD = EuDist2(fea);
%t = mean(mean(tmpD));
%W = exp(-tmpD/(2*t^2));
%W = max(W,W');
%idx = checkClustering(W,NumC);

res = bestMap(ClusterLabels,idx);
ac = length(find(ClusterLabels == res))/length(ClusterLabels);
nmi = MutualInfo(ClusterLabels,res);
end
