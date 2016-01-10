function sA = ScaleRow(A)
%% scale the row to [0,1]
sA = bsxfun(@minus,A,min(A,[],2));
sA = bsxfun(@rdivide,sA,max(sA,[],2)); 
sA(~isfinite(sA)) = 0;
end
