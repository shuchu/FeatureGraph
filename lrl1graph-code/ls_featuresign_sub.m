%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [s, fobj] = ls_featuresign_sub (B, S, x, BtB, Btx, L, i, alpha, gamma, sinit)

[N,M] = size(B);

rankB = rank(BtB);
% rankB = min(size(B,1)-10, size(B,2)-10);

% Step 1: Initialize
usesinit = false;
if ~exist('sinit', 'var') || isempty(sinit)
    sinit= [];
    s= sparse(zeros(M,1));
    theta= sparse(zeros(M,1));
    act= sparse(zeros(M,1));
    allowZero = false;
else
    % sinit = [];
    s= sparse(sinit);
    theta= sparse(sign(s));
    act= sparse(abs(theta));
    usesinit = true;
    allowZero = true;
end


L_new = L(:,i);
L_new(i) = 0;
P = S*L_new;

fobj = fobj_featuresign(s, B, x, BtB, Btx, P, L, i, alpha, gamma);

ITERMAX=1000;
optimality1=false;
for iter=1:ITERMAX
    % check optimality0
    act_indx0 = find(act == 0);
    
    grad = BtB*sparse(s)+alpha*L(i,i)*sparse(s)+alpha*P - Btx;
    theta = sign(s);

    optimality0= false;
    % Step 2
    [mx,indx] = max (abs(grad(act_indx0)));

    if ~isempty(mx) && (mx >= gamma) && (iter>1 || ~usesinit)
        act(act_indx0(indx)) = 1;
        theta(act_indx0(indx)) = -sign(grad(act_indx0(indx)));
        usesinit= false;
    else
        optimality0= true;
        if optimality1
            break;
        end
    end
    act_indx1 = find(act == 1);

    if length(act_indx1)>rankB
        %warning('sparsity penalty is too small: too many coefficients are activated');
        %return;
    end

    if isempty(act_indx1) %length(act_indx1)==0
        % if ~assert(max(abs(s))==0), save(fname_debug, 'B', 'x', 'gamma', 'sinit'); error('error'); end
        if allowZero, allowZero= false; continue, end
        return;
    end

    % if ~assert(length(act_indx1) == length(find(act==1))), save(fname_debug, 'B', 'x', 'gamma', 'sinit'); error('error'); end
    k=0;
    while 1
        k=k+1;

        if k>ITERMAX
            warning('Maximum number of iteration reached. The solution may not be optimal');
            % save(fname_debug, 'B', 'x', 'gamma', 'sinit');
            return;
        end

        if isempty(act_indx1) % length(act_indx1)==0
            % if ~assert(max(abs(s))==0), save(fname_debug, 'B', 'x', 'gamma', 'sinit'); error('error'); end
            if allowZero, allowZero= false; break, end
            return;
        end

        % Step 3: feature-sign step
        [s, theta, act, act_indx1, optimality1, lsearch, fobj] = compute_FS_step (s, B, x, BtB, Btx, P, L, i, theta, act, act_indx1, alpha, gamma);

        % Step 4: check optimality condition 1
        if optimality1 break; end;
        if lsearch >0 continue; end;

    end
end

if iter >= ITERMAX
    warning('Maximum number of iteration reached. The solution may not be optimal');
    % save(fname_debug, 'B', 'x', 'gamma', 'sinit');
end

if 0  % check if optimality
    act_indx1 = find(act==1);
    grad =  BtB*sparse(s)+alpha*L(i,i)*sparse(s)+alpha*P - Btx;
    norm(grad(act_indx1) + gamma.*sign(s(act_indx1)),'inf')
    find(abs(grad(setdiff(1:M, act_indx1)))>gamma)
end

fobj = fobj_featuresign(s, B, x, BtB, Btx, P, L, i, alpha, gamma);

return;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [s, theta, act, act_indx1, optimality1, lsearch, fobj] = compute_FS_step (s, B, x, BtB, Btx, P, L, idx, theta, act, act_indx1, alpha, gamma)

s2 = s(act_indx1);
% B2 = B(:, act_indx1);
BtB2 = BtB(act_indx1, act_indx1);
theta2 = theta(act_indx1);


a = L(idx,idx)*alpha*ones(size(act_indx1));
%a = L(idx,idx)*alpha*eye(size(act_indx1,1));
% call matlab optimization solver..
s_new = (BtB2+diag(a)) \ ( Btx(act_indx1) - gamma.*theta2 -alpha*P(act_indx1)); % RR

% opts.POSDEF=true; opts.SYM=true; % RR
% s_new = linsolve(BtB2, ( Btx(act_indx1) - gamma.*theta2 ), opts); % RR
optimality1= false;
if (sign(s_new) == sign(s2)) 
    optimality1= true;
    s(act_indx1) = s_new;
    fobj = 0; 
    %fobj = fobj_featuresign(s, B, x, BtB, Btx, P, L, idx, alpha, gamma);
    lsearch = 1;
    return; 
end

% do line search: s -> s_new
progress = (0 - s2)./(s_new - s2);
lsearch=0;

a= 0.5*sum((B(:,act_indx1)*(s_new-s2)).^2)+0.5*alpha*L(idx,idx)*(s_new-s2)'*(s_new-s2);
b= (s_new-s2)'*(alpha*P(act_indx1)-Btx(act_indx1)) + (s2'*BtB2+ alpha*L(idx,idx)*s2')*(s_new-s2);

fobj_lsearch = gamma*sum(abs(s2));
[sort_lsearch, ix_lsearch] = sort([progress',1]);
remove_idx=[];
for i = 1:length(sort_lsearch)
    t = sort_lsearch(i); if t<=0 || t>1 continue; end
    s_temp= s2+ (s_new- s2).*t;
    fobj_temp = a*t^2 + b*t + gamma*sum(abs(s_temp));
    if fobj_temp < fobj_lsearch
        fobj_lsearch = fobj_temp;
        lsearch = t;
        if t<1  remove_idx = [remove_idx ix_lsearch(i)]; end % remove_idx can be more than two..
    elseif fobj_temp > fobj_lsearch
        break;
    else
        if (sum(s2==0)) == 0
            lsearch = t;
            fobj_lsearch = fobj_temp;
            if t<1  remove_idx = [remove_idx ix_lsearch(i)]; end % remove_idx can be more than two..
        end
    end
end

% if ~assert(lsearch >=0 && lsearch <=1), save(fname_debug, 'B', 'x', 'gamma', 'sinit'); error('error'); end

if lsearch >0
    % update s
    s_new = s2 + (s_new - s2).*lsearch;
    s(act_indx1) = s_new;
    theta(act_indx1) = sign(s_new);  % this is not clear...
end

% if s encounters zero along the line search, then remove it from
% active set
if lsearch<1 && lsearch>0
    %remove_idx = find(s(act_indx1)==0);
    remove_idx = find(abs(s(act_indx1)) < eps);
    s(act_indx1(remove_idx))=0;

    theta(act_indx1(remove_idx))=0;
    act(act_indx1(remove_idx))=0;
    act_indx1(remove_idx)=[];
end
%fobj_new = 0; 
fobj_new = fobj_featuresign(s, B, x, BtB, Btx, P, L, idx, alpha, gamma);

fobj = fobj_new;

return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [f, g] = fobj_featuresign(s, B, x, BtB, Btx, P, L, i, alpha, gamma)

f= 0.5*(norm(x-B*s)^2+alpha*L(i,i).*(s'*(s+2*P)));
f= f+ gamma*norm(s,1);

if nargout >1
    g = BtB*s+alpha*L(i,i)*s+alpha*P - Btx;
    g= g+ gamma*sign(s);
end

return;

%%%%%%%%%%%%%%%%%%%%%