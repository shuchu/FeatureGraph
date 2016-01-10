function [h] = doubleSideCoherence(data)
% calcualte the single side coherence of data matrix. Feature side.
% input:
%   data:  "n x m" matrix, row: samples, col: features. matrix is NOT
%          necessary normalized.
% output:
%   h: coherence matrix, values range (0,1);

% calcualte column length
nm = sqrt(sum(data .^ 2, 1));
nm(~isfinite(nm)) = 1;
t = nm' * nm;

dotproduct = @(XI,XJ) ( XI * XJ');
h = squareform(pdist(data',@(Xi,Xj) dotproduct(Xi,Xj)));

h = h ./ t;
end

