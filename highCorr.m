function [v,h] = highCorr(y, Phi)
% Phi*x = y;
% Phi: Dictionary. (m x n)
% y: signal
% h: the index of closest Atom
% v: the residual. Euclidean 2 norm.

[~,n] = size(Phi);
col2Norm = sum(Phi.^2,1)';
e = norm(y)^2 - max(Phi'*y, zeros(n,1)).^2./col2Norm;
[v,h] = min(e);
end