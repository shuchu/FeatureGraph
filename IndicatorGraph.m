function [h] = IndicatorGraph(X,G,Y,K)
% Given Feature Graph 'G', and Indicator vector 'Y', find 'K' features;
%
% for 'G', each column is the out edges/weight
%
% input:
%   X -- data, normalized, center, unit length; column is one vector
%   G -- feature graph; weighted, directed, column is out edges
%   Y -- indicator vectors, number equals to the number of clusters, column wise
%   K -- the number of required feature;
%  
% output:
%   h -- the selected feature set

[n,d] = size(X);
if K > n,
    h = 1:n;
    return
end

% find the most compressible features for indicator vectors
Y = normalize(Y); %% normalization
dy = size(Y,2);
iy = zeros(dy,1);
R = Y;

for i=1:dy,
    y = Y(:,i);
    e = norm(y)^2 - max(X'*y,zeros(n,1)).^2;
    [~,iy(i)] = min(e);
    x_est = lsqnonneg(Phi(:,iy(i)),y);
    R(:,i) = R(:,i) - Phi(:.iy(i))*x_est;
end

% local search over graph 
%each loop, select 'dy' feature, then rank them by the approximation error
%idea: 
%  1. check one-ring neighbor.
%  2, find the most compressible node, mark it as the next move.
%  3. rank all 'dy' moves, check its approximation error gain. highest first
res = zeros(dy,1);
pre_res = zeros(dy,1); %% initial value
fea_path = zeros(dy,d);
fea_path(:,1) = iy; % the first node is iy
ite = 1;
selected = zeros(d,1);
selected(iy,1) = 1;

while K > 0,
    for i = 1:dy,
       res(i) = norm(R(:i))^2;
       if abs(pre_res(i) - res(i)) < 1e-5, break; end;
       
       %find one ring neighbor as dictionary
       [~,ids] = find(G(:,fea_path(ite,i)) > 0);
       % remove selected ids;
       ids(logical(selected(ids))) = [];
       if length(ids) == 0, break; end;
       D = X(:,ids);
       y = R(:,i);
       e = norm(y)^2 - max(D'*y,zeros(n,1)).^2;
       [~,id] = min(e);
       gid = ids(id);%% id of graph node
       fea_path(ite+1,i) = gid;
       x_est = lsqnonneg(X(:,fea_path(1:ite+1,i)),y);
       R(:,i) = R(:,i) - X(:,fea_path(1:ite+1,i))*x_est;
       pre_res = res;
    end
    
    %% if  K-K*ite < dy, we only selected top ones.
    req_fea_num = K-K*ite;
    if req_fea_num < dy,
        [~,id] = sort(res);
        fea_path(ite+1,id(1:K-req_fea_num)) = 0;
    end
    ite += 1;
end %% end while

h = fea_path;
end
