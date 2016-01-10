function [perf,alpha] = l1graph(data,k,tlabel,opt,lambda)

% X: d*n data matrix
% lambda 0.5*||y - A*x||^2 + lambda*||x||_1

%%%%%parameter set up%%%%%%%%%%%%%%%%%%%%%%%
%lambda = 0.1;
%%%%%parameter set up%%%%%%%%%%%%%%%%%%%%%%%

X = data';
[d,n] = size(X);
X = X./repmat(sqrt(sum(X.^2)),d,1);
Xinit = zeros(n+d-1,1);
talpha = zeros(n+d-1,n);
%matlabpool open;
for i = 1:n,
    fprintf('process datum %d\n', i);
    Xflag = ones(1,n); Xflag(i) = 0; Xflag = logical(Xflag);
    A = [X(:,Xflag) eye(d)];
    Y = X(:,i);
    Xout = l1ls_featuresign (A, Y, lambda/2, Xinit);
    talpha(:,i) = Xout;
end
%matlabpool close;
alpha = zeros(n);
for i = 1:n,
    alpha(:,i) = [talpha(1:i-1,i);0;talpha(i:n-1,i)];
end

W = .5*(abs(alpha)+abs(alpha'));
%addpath(genpath('.\utility'));

perf = sc(k,W,tlabel,opt.km_iter);






