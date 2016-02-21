function [H] = LCC(G,theta)
% Label Local Compressible Chains (LCC) of a given graph with threshold theta;
% input:
%   G -- directed, weighted graph.
%   theta -- threshold of edge weight.
% output:
%   H -- labels of different groups. default 0 (if not belonging to any groups).


if (theta <= 0.0)
    theta = mean(mean(G));
end

%% size of graph
N = size(G,1);
H = zeros(N,1); 

%% iterative visit all nodes
curr_g = 1; %% label of first group
for i=1:N
    
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
        [oid,~] = find(G(:,id) > theta);
        for j=1:length(oid)
            if H(oid(j)) ~= 0
                continue;
            end
            
            H(oid(j)) = curr_g;
            s.push(oid(j));
        end
        % check out edges, which is column
        [~,iid] = find(G(id,:) > theta);
        for j=1:length(iid)
            if H(iid(j)) ~= 0
                continue;
            end

            H(iid(j)) = curr_g;
            s.push(iid(j));
        end
     end
    
     curr_g = curr_g + 1;
end %% end for


end
