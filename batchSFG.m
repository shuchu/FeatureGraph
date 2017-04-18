diary('running.log')
diary on

warning('off','all');
%% batch create L1 Graph with Ranked Dictionary
file_list = dir('*_nm.mat');
N = size(file_list,1);

for i = 1:N
    file_name = file_list(i).name;
    disp(file_name)
    load(file_name)
    
    tic;
    [G, myres] = OMP_mat_func(fea,100,0.01);
    toc;
    
    output = sprintf('%s_l1.mat',file_name(1:end-4));
    save(output,'G','myres');
    clear fea,gnd,G,myres;
end

diary off


