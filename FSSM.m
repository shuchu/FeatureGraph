function [fK,fg,g] = FSSM(Data,K)
%  Feature selection by sparse modeling (FSSM). Unsupervised.
%  Input: 
%     Data -- input data matrix. Row: sample, Col: feature. assume
%     normalized.
%     K    -- number of cluster
%  Output:
%     fK -- The best K features.
%     fg -- feature groups.
%     g  -- featuer weights matrix.
%  Comments:
%     require Dr. Deng Cai's "Eigenmap.m" code.
%
%  shhan@cs.stonybrook.edu
%  10/08/2015

%[row,col] = size(Data);

% model the Data
W = L1GraphGreedy(Data',1e-5);
W = (W+W')/2;

% calculate the eigenvectors
Y = Eigenmap(W,K);

% calculate the similarity among Features and Eigenvectors.
% data = NMRow(Data')';
% %g = abs(data'*Y);  %% size: #feature x K
% g = groupFeature(data,Y);
% v = var(g,[],1);
% [~,fg] = sort(v,'descend');
% [~,fK] = max(g,[],1);
end