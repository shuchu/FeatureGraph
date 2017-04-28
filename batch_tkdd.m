thresh_fail_sc = 15.0; % only allow 15 degree differance
thresh_fail_sc = (thresh_fail_sc*pi)/180.0;

file_list ={'orl','yale','warpPIE10P','orlraws10p','basehock','relathe','pcmac','reuters21578','lymphoma','lung','carcinom','cll_sub_111'};
%file_list ={'reuters21578','lymphoma','lung','carcinom','cll_sub_111'};
%file_list = {'relathe'};

num_files = length(file_list);
FeaNum = [10:5:60];

my_nmi = zeros(num_files,length(FeaNum));
my_acc = zeros(num_files,length(FeaNum));


for i = 1:num_files
	file_name = file_list{i};
	disp(file_name)
    data_file_name = sprintf('%s_nm.mat',file_name);
    graph_file_name = sprintf('%s_nm_l1.mat',file_name);
	load(data_file_name);
    load(graph_file_name);

    % check MCFS performance
    %tmpD = EuDist2(fea);
    %t = mean(mean(tmpD));
    %Woptions.k = 0;
    %Woptions.t = t;
    %options.W = constructW(fea,Woptions);
    
    %options=[];
    %[FeaIndex,FeaNum] = MCFS_p(fea,FeaNum,options);

    %for j = 1:length(FeaNum)
    %    sf_idx = FeaIndex{j};
    %    [my_nmi(i,j), my_acc(i,j)] = checkSC(fea(:,sf_idx),max(gnd),gnd);
    %end
    
    % check spectral clustering performance over original data. 
    [my_nmi(i,1),my_acc(i,1)] = checkSC(fea,max(gnd),gnd);

    clear fea gnd file_name options ;
end

