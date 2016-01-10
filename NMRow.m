function nA = NMRow(A)
%% normalize the row of matrix A
nA = bsxfun(@rdivide,A,sqrt(sum(A.^2,2)));
nA(~isfinite(nA)) = 0;
end
