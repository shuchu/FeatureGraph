diary on
diary('RunAllLog.txt');

dataset = {'BreastTissue','COIL20','BrainTumor1','BrainTumor2','Colon','Leukemia1','Leukemia2','Lung','MLL'};


N = size(dataset,2);

for i=1:N

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

%% normalization
X = Data';
[M,N] = size(X); %% M: #features; N: #samples
mu = mean(X,2);
X = X - mu*ones(1,N);
d = sqrt(sum(X.^2,2));
d(d==0) = 1;
X = X./(d*ones(1,N));


%% build sample graph.
myG.SG = L1GraphGreedy(X,1e-5);

%% build feature graph.
myG.FG = FeatureGraph(X,1e-5);

%% save data.
ofname = sprintf('%s_g.mat',dataset{i});
save(ofname,'myG');

%%% run test scripts;
%Data = zscore(Data); %% z-score normalization
%checkTimeSpec(Data,NumC,ClusterLabels);

end %% end for

diary off;
