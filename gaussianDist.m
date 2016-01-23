function [h] = gaussianDist(fea)
%% fea: row -- sample, col -- feature
%%
%
d = EuDist2(fea);
opts.t = mean(mean(d));
h = constructW(fea,opts);
end
