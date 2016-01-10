function [h] = singleSideCoherence(data)
% calcualte the single side coherence of data matrix. Feature side.
% input:
%   data:  "n x m" matrix, row: samples, col: features. matrix is NOT
%          necessary normalized.
% output:
%   h: coherence matrix, values range (0,1);

% calcualte column length
nm = sum(data .^ 2, 1);


dotproduct = @(XI,XJ) ( XI * XJ');
h = squareform(pdist(data',@(Xi,Xj) dotproduct(Xi,Xj)));
h = h ./ repmat(nm, size(data,2),1);
end

