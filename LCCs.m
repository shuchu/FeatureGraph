function [H,in_deg] = LCCs(G,theta)
% Label Local Compressible Chains (LCC) of a given graph with threshold theta;
% sorted version. sorted by the in-degree of nodes.
% input:
%   G -- directed, weighted graph.
%   theta -- threshold of edge weight.
% output:
%   H -- labels of different groups. default 0 (if not belonging to any groups).
%   id_deg  -- in-degree

if (theta <= 0.0)
    theta = mean(mean(G));
end

%% size of graph
N = size(G,1);
H = zeros(N,1);

%% sort nodes by its in-degree
L = logical(G);
in_deg = sum(L,1);
[~,idx_s] = sort(in_deg,'descend');

%% iterative visit all nodes
curr_g = 1; %% label of first group
for ii =1:N
    i = idx_s(ii); 

    if H(i) ~= 0, continue; end;

    s = CStack();
    s.push(i);
    
    if (H(i) ==0)
        H(i) = curr_g;
    end

    while (~s.isempty())
        id = s.top();
        s.pop();
        
        % check out edges, which is column
        oid = find(G(:,id) > theta);
        for j=1:length(oid)
            if H(oid(j)) == 0
              H(oid(j)) = curr_g;
              s.push(oid(j));
            end;
        end
        % check in edges, which is row 
        iid = find(G(id,:) > theta);
        for j=1:length(iid)
            if H(iid(j)) == 0
              H(iid(j)) = curr_g;
              s.push(iid(j));
            end;
        end
     end
    
     curr_g = curr_g + 1;
end %% end for


end
