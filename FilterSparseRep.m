function [G,R] = FilterSparseRep(nFea,W,deg)
% filter the lower quality linear representation.
% each row of W is a sparse linear representation.
% each feature (column) of nFea is normalized to united length.
%
% input:
% 	nFea  -- feature matrix, each feature vector is normalized to unit length.
%	W     -- L1 graph
%   deg -- the threshold of linear regression error.
% output:
%	G     -- filtered sparse graph.
%       R     -- redundancy:  cos^2
%

N = size(W,1);
if N ~= size(nFea,2)
	error('the dimension of matrices are not match!')
end

R  = zeros(N,1);
for i = 1:N
    recover_sig =  nFea * W(:,i);
    recover_sig = recover_sig / norm(recover_sig,2);
    R(i) = acos(dot(nFea(:,i),recover_sig));
end

filtered_idx = find(R > deg);
G = W;
G(:,filtered_idx) = 0;

end


