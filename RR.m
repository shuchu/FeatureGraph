function [idx,perf] = RR(Data,ClusterLabels,NumC,Ite)
%% !!!remember: we are doing on feature side!
warning('off','all');
%% normalize the data
X = normalize(Data);

%% remove redundant features iteratively
if (Ite <= 0), Ite = 1; end;
idx = cell(Ite,1);
% threshold
theta = 0.5;
[n,d] = size(X);
idf = 1:d;
num_nd = length(find(idf > 0));
perf = zeros(Ite+1,2);
curr_idx = idf;

[perf(1,1),perf(1,2)] = kmeansPer(X,ClusterLabels,NumC);

% iteration begin
for it = 1:Ite   
    %build L1 graph
    G = myl1graph(X(:,curr_idx)',0.1);
    G = abs(G);
    % find highly correlated edges/node pairs
    [u,v] = find(G >= theta);
    for i =1:length(u)
        l = u(i); r=v(i);
       if (G(l,r) >= theta && G(r,l) >= theta)
           % find one pair, now decide which one to be removed
           if G(l,r) > G(r,l)
               idf(curr_idx(l)) = 0; %% remove 'r'
           elseif G(l,r) == G(r,l)
               if length(G(:,l)) >= length(G(:,r))
                   idf(curr_idx(l)) = 0;
               else
                   idf(curr_idx(r)) = 0;
               end
           else
               idf(curr_idx(r)) = 0;
           end
       end
    end
   
    %% check clustering performance
    curr_idx = idf(logical(idf));
    idx{it} = curr_idx;
    if length(curr_idx) < num_nd
        [perf(it+1,1),perf(it+1,2)] = kmeansPer(X(:,curr_idx),ClusterLabels,NumC);
        num_nd = length(curr_idx);
    else
        break;
    end
end
end