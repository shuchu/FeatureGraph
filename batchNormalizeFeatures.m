%% load data in "../data"
file_list = dir('*.mat');
N = size(file_list,1);

for i = 1:N
    file_name = file_list(i).name;
    disp(file_name)
    load(file_name);
    size(fea)
    fea = NMRow(fea')';
    %test
    %norm(fea(:,1))
    
    nm_file_name = sprintf('./nm/%s_nm.mat',file_name(1:end-4));
    disp(nm_file_name)
    save(nm_file_name,'fea','gnd')

    %clear
    clear fea gnd;
end
