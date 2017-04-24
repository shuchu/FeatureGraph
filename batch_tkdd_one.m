clear;

thresh_fail_sc = 15.0; % only allow 15 degree differance
thresh_fail_sc = (thresh_fail_sc*pi)/180.0;
%thresh_rd = 0.3; 

file_list ={'orl','yale','warpPIE10P','orlraws10p','basehock','relathe','pcmac','reuters21578','lymphoma','lung','carcinom','cll_sub_111'};
%file_list ={'orl','yale','warpPIE10P','orlraws10p','basehock','relathe','pcmac','reuters21578','lymphoma'};

num_test = length(10);
num_file = size(file_list,2)

my_nmi = zeros(num_test,num_file);
my_acc = zeros(num_test,num_file);
my_size = zeros(num_test,num_file);

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
    my_size(i,k) = length(remained_idx);
    filtered_fea = fea(:,remained_idx) ;
    [my_nmi(i,k),my_acc(i,k)] = checkSC(filtered_fea,max(gnd),gnd);

    clear label;
end
end

