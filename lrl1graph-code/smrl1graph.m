function [perf,alpha] = smrl1graph(data,k,tlabel,opt)

gamma = 0.02:0.02:0.1;
palpha = 30;
nl = length(gamma);

perf = zeros(3,nl);
alpha = cell(1,nl);

parfor i = 1:nl,
    [perf(:,i),alpha{i}] = mrl1graph(data,k,tlabel,opt,palpha,gamma(i));
end