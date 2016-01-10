function [nmi,ac] = kmeansPer(data,ClusterLabels,NumC)
rng('default');
%data = ScaleRow(data')';
[labels] = litekmeans(data,NumC,'replicates',20);
res = bestMap(ClusterLabels,labels);
ac = length(find(ClusterLabels == res)) /length(ClusterLabels);
nmi = MutualInfo(ClusterLabels,res);
disp(['NMI: ', num2str(nmi),' AC: ', num2str(ac)]);
end