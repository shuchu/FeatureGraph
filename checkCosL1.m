function [h] = checkCosL1(Data,NumC,ClusterLabels)
% check the Clustering performance by feature selection with Cosine 
% similarity, and L1 similarity.  The top NumC eigenvectors are used
% as indication vectors.
%
%
warning('off','all');
% L1 graph
% W = L1GraphGreedy(Data',1e-5);
% W = (W+W')/2;

%%debug, normalization
Data = zscore(Data);

% Knn Gaussian similarity.
% use Euclidean distance, and Gaussian similarity
D = EuDist2(Data);
Woptions.k=5;
Woptions.t= mean(mean(D));
W = constructW(Data,Woptions);

% calculate the eigenvectors
Y = Eigenmap(W,NumC);

% find the top NumC features using cosine similarity.
sim_cos = squareform(pdist([Y,Data]','cosine')); %% put indicators at beginning 
%sim_cos = sim_cos + eye(size(sim_cos,1)); %% avoid itself for each feature.
fea_cos_idx = zeros(NumC,1);
for i=1:NumC
    [~,fea_cos_idx(i)] = min(sim_cos(i,NumC+1:end));
end

fea_cos_idx = unique(fea_cos_idx); %% avoid duplication.
disp('cosine similarity: ');
kmeansPer(Data(:,fea_cos_idx),ClusterLabels,NumC);

% find most compressable feature to Y from Data feature
options =[];
[fea_l1_idx,~] = MCFS_p(Data,NumC,options);

% clustering performance of new data
idx = cell2mat(fea_l1_idx);
disp('L1 similairty: ');
kmeansPer(Data(:,idx),ClusterLabels,NumC);
warning('on','all');
h=0;
end