%% using Dr. Cai Deng's Eigenmap code
%addpath('./caideng/');

%assume existing parameters:
%  Data: data matrix, row: sample, col: feature.
%  NumC: number of clusters.
%  ClusterLabels: ground truth of labels.
%

%%%%%%%%%%%%%% 
% run feature graph, and local search
%%%%%%%%%%%%%%
%
% parameters:
K = 10;
lambda = 0.1;

X = normalize(Data);
[n,d] = size(X);

%% find indcator vector
D = EuDist2(X);
opts.t = mean(mean(D));
W = constructW(X,opts);
Y = Eigenmap(W,NumC);

%% build sparse graph
%% 1. for indicator vector side
Y = normalize(Y);
Xinit = zeros(n+d,1);
talpha = zeros(n+d,NumC);

for i = 1:NumC,
    XX = [X eye(n)];
    y = Y(:,i);
    Xout = l1ls_featuresign(XX,y,lambda/2,Xinit);
    talpha(:,i) = Xout;
end
alpha = talpha(1:d,:);

mcfs_idx = zeros(d,1);
for i=1:size(alpha,2)
   id = find(alpha(:,i)); 
   mcfs_idx(id) = 1;
end

mcfs_idx = find(mcfs_idx);


%% 2. build feature graph
%G = l1graphknn(Data,lambda,K);


%% check performance
% find the most similar features in Graph
%sim = Y'*X; %% NumC x d
%[~,fs_1] = max(sim');

%. basic performance, NumC feaures
%[nmi,ac] = kmeansPer(X(:,fs_1),ClusterLabels,NumC)

%2. 




%==============================================================
%  Check inconsistency
%==============================================================
%
%
%fea = Data;
%gnd = ClusterLabels;
%nClusters = length(unique(gnd)); %% or NumC
%%scale the feature of input data
%fea = ScaleRow(fea')';
%
%rng('default');
%%Unsupervised feature selection using MCFS
%options = [];
%options.nUseEigenfunction = 9;  
%%FeaNumCandi = [5:5:40];
%[FeaIndex,FeaNumCandi,egvec,err] = myMCFS_p(fea,FeaNumCandi,options);
%
%%Clustering using selected features
%disp(['#feature ','SR err ','NMI ','AC']);
%for i = 1:length(FeaNumCandi)
%  SelectFeaIdx = FeaIndex{i};
%  feaNew = fea(:,SelectFeaIdx);
%  rng('default');
%  label = litekmeans(feaNew,nClusters,'Replicates',20);
%  res = bestMap(gnd,label);
%  ACC = length(find(gnd==res))/length(gnd);
%  MIhat = MutualInfo(gnd,res);
%  disp([num2str(FeaNumCandi(i)),' ',num2str(err{i},'%.4f'),' ',num2str(MIhat,'%.f'),' ',num2str(ACC,'%.4f')]);
%end



%==============================================================
%  find most compressible K features.
%==============================================================

% W = L1GraphGreedy(Data',1e-5);
% W = (W+W')/2;
% 
% % calculate the eigenvectors
% Y = Eigenmap(W,NumC);
% 
% % find sparse coding of Y with dictionary as Data
% [n,m] = size(Data);
% H = zeros(m,NumC);
% for i = 1:NumC
%     H(:,i) =  myNNOMP(Y(:,i),Data,1e-5);
% end
% 
% [~,I] = max(H);
% 
% % clustering performance of new data
% kmeansPer(Data(:,I),ClusterLabels,NumC);



%==============================================================
%  Detect noise feature
%==============================================================
% data = ScaleRow(Data')';
% kmeansPer(data,ClusterLabels,NumC);
% W_f = L1GraphGreedy(data,1e-5);
% 
% v = weightVar(W_f,'IN');
% %[sv, id] = sort(v,'descend');
% idx = find(v > mean(v));
% size(idx)
% kmeansPer(data(:,idx),ClusterLabels,NumC);
% 
% v = weightVar(W_f,'OUT');
% %[sv, id] = sort(v,'descend');
% idx = find(v > mean(v));
% size(idx)
% kmeansPer(data(:,idx),ClusterLabels,NumC);



% % model the Data
% W = L1GraphGreedy(Data',1e-5);
% W = (W+W')/2;
% 
% % calculate the eigenvectors
% Y = Eigenmap(W,NumC);
% 
% %% use Cai Deng's LARs solver
% options.W = W;
% options.nUseEigenfunction = NumC;
% options.Method = 'LASSO_LARs';
% options.LASSOway = 'LARs';
% options.ReguType = 'RidgeLasso';
% options.LassoCardi = NumC;
% 
% eigvectorAll = SR(options, Y, Data);


%==============================================================
%   Check performance
%==============================================================
% 
% fsK = zeros(NumC,1);
% for i = 1:NumC
%     ids = find(fea_grp == i);   
%     if ~isempty(ids)
%         i
%          kmeansPer(Data(:,ids),ClusterLabels,NumC);
%         [~,id] = max(fea_coe(ids));
%         fsK(i) = ids(id);
%     end
% end
% 
% disp('TopK')
% fsK = fsK(logical(fsK > 0));
% kmeansPer(Data(:,fsK),ClusterLabels,NumC);

%==============================================================
%   Fail
%==============================================================

%% obtain the ranked feature
%[fK,fg,g] = FSSM(Data,NumC);
% % %% check performance
% % fea_size = 5:20:400;
% % t = length(fea_size);
% % p = zeros(t+2,2);
% % 
% % % first check all features
% % [p(1,1),p(1,2)] = kmeansPer(Data,ClusterLabels,NumC);
% % 
% % % different rank method.
% % ab = Data'*Y;
% % na = sum(Data.^2,1);
% % nb = sum(Y.^2,1);
% % g = ab./sqrt(na'*nb);
% % 
% % 
% % % first check the top K features
% % data = Data(:,fK);
% % [p(2,1),p(2,2)] = kmeansPer(data,ClusterLabels,NumC);
% % 
% % for i = 1:t
% % data = Data(:,fg(1:fea_size(i)));
% % [p(i+2,1),p(i+2,2)] = kmeansPer(data,ClusterLabels,NumC);
% % end


%==============================================================
%   Misc
%==============================================================

%% data normalization
%data = ScaleRow(data_fs')';
%[n,m] = size(data);


%% Calculate Eigenvector
%  Let A to be symmetric. 
% K = NumC;
% A = (W_s + W_s')/2;
% D = sum(A,2);
% Y = Eigenmap(A,K);

%% group features into K groups. 
% nfea = NMRow(fea')';
% g = fea'*v; %% g: m x k;
% [fea_coe,fea_grp] = max(abs(g),[],1);
% fsK = zeros(K,1); 
% [~,idx] = sort(fea_coe,'descend');

% for i = 1:K
%     ids = find(fea_grp == i);
%     if ~isempty(ids)
%         [~,id] = max(fea_coe(ids));
%         fsK(i) = ids(id);
%     end
% end
% 
% ub = fsK(find(fsK>0));

%% check Feature Selection performance
% 
% rng('default');
% [labels] = litekmeans(data,NumC,'replicates',20);
% res = bestMap(ClusterLabels,labels);
% ac = length(find(ClusterLabels == res)) /length(ClusterLabels);
% nmi = MutualInfo(ClusterLabels,res);
% 
% 
% disp(['NMI: ', num2str(nmi),' AC: ', num2str(ac)]);

%% =========================== Obsolete ==========================
%disp(['NMI: ', num2str(nmi) ;' AC: ', num2str(ac)]);
% report performance
%disp(['NMI: ', num2str(mean(nmis)), '+', num2str(std(nmis)), ...
%      ' AC:', num2str(mean(acs)), '+',num2str(std(acs))]);


%% draw image
% 
% I1 = reshape(data(1,:),32,32); %% column first
% id = [];  %% sort coherence index, small to large
% 
% % column croodiate
% y = floor( id ./32);
% x = id - y*32;
% y = y+1;
% 
% 
% s = 10;
% low_s = low65(1:s);
% high_s = high579(1:s);
% 
% 
% for i = 0:19
%    I = reshape(data(i*72+1,:),32,32);
%    figure, imagesc(I);
%    hold on;
%    % high std
%    plot(mod(high_s,32),floor(high_s./32)+1,'r+');
%    %low std
%    plot(mod(low_s,32),floor(low_s./32)+1,'gd');
%    hold off;
% end


%% calcualte sparse coding
% [N,M] = size(Data);
% K = NumC;
% H = zeros(M,K);
% for i = 1:K
%     H(:,i) =  myNNOMP(Y(:,i),Data,1e-5);
% end
