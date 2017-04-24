clear;

thresh_fail_sc = 15.0; % only allow 15 degree differance
thresh_fail_sc = (thresh_fail_sc*pi)/180.0;

%file_list ={'orl','yale','warpPIE10P','orlraws10p','basehock','relathe','pcmac','reuters21578','lymphoma','lung','carcinom','cll_sub_111'};

file_list={'basehock'};
num_file = size(file_list,2)

% start for each data
for k = 1:num_file
    file_name = file_list{k};

disp(file_name)
data_file_name = sprintf('%s_nm.mat',file_name);
graph_file_name = sprintf('%s_nm_l1.mat',file_name);
load(data_file_name);
load(graph_file_name);

% filter failed recovered vectors
[GG,R] = FilterSparseRep(fea,G,thresh_fail_sc);

GG = abs(GG);
mm_idx = find(GG);
max_v = max(GG(mm_idx));
min_v = min(GG(mm_idx));
bin_w = (max_v-min_v) / 10;
th = (max_v-bin_w):-bin_w:(min_v+bin_w);

num_th = length(th);
selected_f = [10:5:60];
num_f = length(selected_f);

my_nmi = zeros(num_f,num_th,num_file);
my_acc = zeros(num_f,num_th,num_file);

% 
for i = 1:length(th)
    % filter the redundancy
    [label, in_deg] = LCCs(GG,th(i));
    filtered_idx = ones(size(G,1),1);
    num_group = max(label);
    for label_ite = 1:num_group
        label_idx = find(label == label_ite);
        group_deg = in_deg(label_idx);
        [~,max_idx] = max(group_deg);
        filtered_idx(label_idx) = 0;
        filtered_idx(label_idx(max_idx)) = 1;
    end

    if (sum(filtered_idx) ~= num_group)
        disp('Error')
        sum(filtered_idx)
        num_group
        return
    end
    
    remained_idx = find(filtered_idx);
    filtered_fea = fea(:,remained_idx) ;

    %check MCFS performance
    %tmpD = EuDist2(filtered_fea);
    %t = mean(mean(tmpD));
    %W = exp(-tmpD/(2*t^2));
    %options.W = max(W,W');
    options = []; 
    [FeaIndex, selected_f] = MCFS_p(filtered_fea,selected_f, options);

    for j = 1:length(selected_f)
      sf_idx = FeaIndex{j};
      try
        [my_nmi(j,i,k),my_acc(j,i,k)] = checkSC(filtered_fea(:,sf_idx),max(gnd),gnd);
      catch
          disp('failed on finding enough eigenvalues');
      end
    end

    clear label;
end
end

