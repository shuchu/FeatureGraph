function [bins,right_edges] = myhistcount(X)
% histogram count of abosulte X into 10 bins
% minimum value always 0, but we not count 0.0 values

X = abs(X);
min_v = 0.0;
max_v = max(max(X));

bin_w = max_v/10;
right_edges = bin_w:bin_w:max_v;
bins = zeros(10,1);

[M,N] = size(X);
for j = 1:N
    for i = 1:M
        if X(i,j) > 0.0
        idx = ceil(X(i,j)/bin_w);
        try
            bins(idx) = bins(idx) + 1;    
        catch
            idx
            return
        end
        end
    end
end
end
