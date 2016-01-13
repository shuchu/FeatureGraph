diary on
diary('RunAllLog.txt');

dataset = {'BreastTissue','COIL20','BrainTumor1','BrainTumor2','Colon','Leukemia1','Leukemia2','Lung','MLL'};


ND = size(dataset,2);

for i=1:ND

clear Data NumC ClusterLabels fea gnd;

disp(dataset{i});
load(dataset{i});

if exist('fea') && exist('gnd')
   Data = fea;
   NumC = length(unique(gnd));
   ClusterLabels = gnd;
end

%%%%%%%%%
% now matlab has variables: Data, ClusterLabels, NumC;
%%%%%%%%%

X = Data';
[M,N] = size(X); %% M: #features; N: #samples
f_K = min(2*N,M-1); 
s_K = min(2*M,N-1);

%% normalization
mu = mean(X,2);
X = X - mu*ones(1,N);
d = sqrt(sum(X.^2,2));
d(d==0) = 1;
X = X./(d*ones(1,N));

%% build feature graph.
%% calculate the KNN of G;
f_dist = X*X';
[~,loc] = maxk(f_dist,f_K);
loc(1,:) = [];
myG.FG = SparseKnnGraph(X',loc,1e-3);

%% build sample graph.
d_dist = X'*X;
[~,loc] = mink(d_dist,s_K);
loc(1,:) = [];
myG.SG = SparseKnnGraph(X,loc,1e-5);


%% save data.
ofname = sprintf('%s_g.mat',dataset{i});
save(ofname,'myG');

%%% run test scripts;
%Data = zscore(Data); %% z-score normalization
%checkTimeSpec(Data,NumC,ClusterLabels);

end %% end for

diary off;
