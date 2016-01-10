function [w] = L1General2_OWL(funObj,w,lambda,options)

%% Process Options
if nargin < 4
    options = [];
end

[verbose,optTol,progTol,maxIter,suffDec,memory] = ...
    myProcessOptions(options,'verbose',1,'optTol',1e-5,'progTol',1e-9,...
    'maxIter',500,'suffDec',1e-4,'memory',10);

if verbose
    fprintf('%6s %6s %12s %12s %12s %6s\n','Iter','fEvals','stepLen','fVal','optCond','nnz');
end

%% Evaluate Initial Point
p = length(w);
[f,g] = pseudoGrad(funObj,w,lambda);
funEvals = 1;

% Check optimality
optCond = max(abs(g));
if optCond < optTol
    if verbose
        fprintf('First-order optimality satisfied at initial point\n');
    end
    return;
end

%% Main loop
for i = 1:maxIter
    
    % Compute direction
    if i == 1
        d = -g;
        t = min(1,1/sum(abs(g)));
        old_fvals = repmat(-inf,[memory 1]);
        fr = f;
    else
        y = g-g_old;
        s = w-w_old;

        alpha = (y'*s)/(y'*y);
        if alpha <= 1e-10 || alpha > 1e10
            fprintf('BB update is having some trouble, implement fix!\n');
            pause
        end
        d = -alpha*g;
        t = 1;

        if i-1 <= memory
            old_fvals(i-1) = f;
        else
            old_fvals = [old_fvals(2:end);f];
        end
        fr = max(old_fvals);
    end
    f_old = f;
    g_old = g;
    w_old = w;
    
    % Compute desired orthant
    xi = sign(w);
    xi(w==0) = sign(-g(w==0));
    
    % Compute directional derivative, check that we can make progress
    gtd = g'*d;
    if gtd > -progTol
        if verbose
            fprintf('Directional derivative below progTol\n');
        end
        break;
    end
    
    % Compute projected point
    w_new = orthantProject(w+t*d,xi);
    [f_new,g_new] = pseudoGrad(funObj,w_new,lambda);
    funEvals = funEvals+1;
    
    % Line search along projection arc
    while f_new > fr + suffDec*g'*(w_new-w) || ~isLegal(f_new)
        t_old = t;
        
        % Backtracking
        if verbose
            fprintf('Backtracking...\n');
        end
        if ~isLegal(f_new)
            if verbose
                fprintf('Halving Step Size\n');
            end
            t = .5*t;
        else
            t = polyinterp([0 f gtd; t f_new g_new'*d]);
        end
        
        % Adjust if interpolated value near boundary
        if t < t_old*1e-3
            if verbose == 3
                fprintf('Interpolated value too small, Adjusting\n');
            end
            t = t_old*1e-3;
        elseif t > t_old*0.6
            if verbose == 3
                fprintf('Interpolated value too large, Adjusting\n');
            end
            t = t_old*0.6;
        end
        
        % Check whether step has become too small
        if max(abs(t*d)) < progTol
            if verbose
                fprintf('Step too small in line search\n');
            end
            t = 0;
            w_new = w;
            f_new = f;
            g_new = g;
            break;
        end
        
        % Compute projected point
        w_new = orthantProject(w+t*d,xi);
        [f_new,g_new] = pseudoGrad(funObj,w_new,lambda);
        funEvals = funEvals+1;
    end
    
    % Take step
    w = w_new;
    f = f_new;
    g = g_new;
    
    % Output Log
    if verbose
        fprintf('%6d %6d %8.5e %8.5e %8.5e %6d\n',i,funEvals,t,f,max(abs(g)),nnz(w));
    end
    
    % Check Optimality
    optCond = max(abs(g));
    if optCond < optTol
        if verbose
            fprintf('First-order optimality below optTol\n');
        end
        break;
    end
    
    % Check for lack of progress
    if max(abs(t*d)) < progTol || abs(f-f_old) < progTol
        if verbose
        fprintf('Progress in parameters or objective below progTol\n');
        end
        break;
    end
    
    % Check for iteration limit
    if funEvals >= maxIter
        if verbose
            fprintf('Function evaluations reached maxIter\n');
        end
        break;
    end
end

end

%% Psuedo-gradient calculation
function [f,pGrad,H] = pseudoGrad(funObj,w,lambda)

[f,g] = funObj(w);

f = f + sum(lambda.*abs(w));

pGrad = zeros(size(g));
pGrad(g < -lambda) = g(g < -lambda) + lambda(g < -lambda);
pGrad(g > lambda) = g(g > lambda) - lambda(g > lambda);
nonZero = w~=0 | lambda==0;
pGrad(nonZero) = g(nonZero) + lambda(nonZero).*sign(w(nonZero));

end

function [w] = orthantProject(w,xi)
w(sign(w) ~= xi) = 0;
end
