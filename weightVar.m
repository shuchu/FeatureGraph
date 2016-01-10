function [v] = weightVar(W,opt)
% calcualte the IN weight variance of graph W. W is directed, weighted
% graph.
%
%

if nargin < 2
   disp('Error, two parameters are required!\n');
   return;
end

[R,C] = size(W);
v = 0;

if strcmp(opt,'IN')
    v = zeros(C,1);
    for i = 1:C
       t = W(:,i);
       t(i) = [];
       v(i) = var(t);
    end
elseif strcmp(opt,'OUT')
    v = zeros(R,1);
    for i = 1:R
       t = W(i,:);
       t(i) = [];
       v(i) = var(t);
    end
end

%that's all.
end 
   