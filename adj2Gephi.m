function h = adj2Gephi(G,fname)
%%% save NODE first
N = size(G,1);
nfname = sprintf('%s_[Nodes].csv',fname);
nfid = fopen(nfname,'w');
fprintf(nfid,'Id\n');
for i=1:N
    fprintf(nfid,'%d\n',i);
end
fclose(nfid);

%%% save Edges
[i j v] = find(G);
efname = sprintf('%s_[Edges].csv',fname);
fid = fopen(efname,'w');
fprintf(fid,'%s,%s,%s\n','Source','Target','Weight');
for k = 1:length(i)
    fprintf(fid,'%d,%d,%.4f\n',i(k),j(k),v(k));
end
fclose(fid);
end
