function [perf,alpha] = mrl1graph(data,k,tlabel,opt,palpha,gamma)

% X: d*n data matrix
% lambda 0.5*||y - A*x||^2 + lambda*||x||_1

%%%%%parameter set up%%%%%%%%%%%%%%%%%%%%%%%
%lambda = 0.1;
%%%%%parameter set up%%%%%%%%%%%%%%%%%%%%%%%

DistL2 = computeDistL2(data);
[n,d] = size(data);
bandwidth = (4/(d+2))^(1/(d+4))*mean(std(data))*n^(-1/(d+4));
h_sc = bandwidth; %0.05*max(sqrt(DistL2(:)));
W = exp(-DistL2/(2*(h_sc^2)));
D = diag(sum(W,2));
L = D-W;


X = data';
[d,n] = size(X);
X = X./repmat(sqrt(sum(X.^2)),d,1);


%%parameter setting%%%%%%%%%%%%%%%%%%%%%%%%%%%
maxIter = 5; maxLIter = 2; 
%palpha = 30; gamma = .01;
%%parameter setting%%%%%%%%%%%%%%%%%%%%%%%%%%%
for LIter = 1:maxLIter,
    S0 = zeros(n-1,1);
    S = zeros(n-1,n);
    for iter = 1:maxIter,
        S0 = S;

        if iter == 1,
            S = mrl1graph_sub(X, palpha, gamma, L);
        else
            S = mrl1graph_sub(X, palpha, gamma, L, S);
        end
        fprintf('norm(S0-S) is %f\n', norm(S0-S,'fro'));
    end
    
    talpha = S;
    alpha = zeros(n);
    for i = 1:n,
        alpha(:,i) = [talpha(1:i-1,i);0;talpha(i:n-1,i)];
    end
    W = .5*(abs(alpha)+abs(alpha'));
    D = diag(sum(W,2));
    L = D-W;
    fprintf('LIter %d \n', LIter);
end

%addpath(genpath('.\utility'));

perf = sc(k,W,tlabel,opt.km_iter);


function [Sout] = mrl1graph_sub(X, alpha, gamma, L, Sinit)

n = size(X,2);
Sout = zeros(n-1,n);

use_Sinit= false;
if exist('Sinit', 'var')
    use_Sinit= true;
end

for i=1:n
    fprintf('mrl1graph_sub: process datum %d\n', i);
    Xflag = ones(1,n); Xflag(i) = 0; Xflag = logical(Xflag);
    B = [X(:,Xflag)];
    BtB = B'*B;
    BtX = B'*X(:,i);

    if use_Sinit
        idx1 = find(Sinit(:,i)~=0);
        rankB = rank(BtB);
        maxn = min(length(idx1), rankB);
        sinit = zeros(size(Sinit(:,i)));
        sinit(idx1(1:maxn)) =  Sinit(idx1(1:maxn), i);
        a = sum(sum(Sinit,2)==0);
        S = [Sout(:,1:i),Sinit(:,(i+1):n)];
        [Sout(:,i), fobj]= ls_featuresign_sub (B, S, X(:,i), BtB, BtX, L, i, alpha, gamma, sinit);
    else
        [Sout(:,i), fobj]= ls_featuresign_sub (B, Sout, X(:,i), BtB, BtX, L, i, alpha, gamma);
    end
        
end






