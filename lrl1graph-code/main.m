windows = 1;

if windows,
    pathsep = '\';
else
    pathsep = '/';
end

utilitypath = ['.',pathsep,'utility'];
addpath(genpath(utilitypath));
%datapath = ['.',pathsep,'Data'];
%addpath(genpath(datapath));

dataname = '';
%data = orl(1:100,:);
%tlabel = orl_tlabel(1:100);

%data = bt;
%tlabel = bt_tlabel;

data = wine;
tlabel = wine_tlabel;


k = length(unique(tlabel));
opt.km_iter = 30;
opt.km_replica = 10;




%[perf.l1perf,l1_alpha] = l1graph(data,k,tlabel,opt,.1,'accuracy');
[perf.l1,l1_alpha] = sl1graph(data,k,tlabel,opt);
[perf.smce] = ssmce(data,tlabel);
[perf.mrl1,mrl1_alpha] = smrl1graph(data,k,tlabel,opt);
alpha0 = zeros(size(data,1));
%alpha0 = l1_alpha;
%L0 = ComputeP(l1_alpha);
%[perf.mrscperf,mrsc_alpha] = runMRSC(data,L0,k,tlabel,opt,alpha0,dataname);


% kmeans
perf.kmeans = mykmeans(data,k,tlabel,opt.km_replica,opt.km_iter);


% spectral clustering
DistL2 = computeDistL2(data);
h_sc = 0.05*max(sqrt(DistL2(:)));
W = exp(-DistL2/(2*(h_sc^2)));
perf.scdefault= sc(k,W,tlabel,opt.km_iter);
