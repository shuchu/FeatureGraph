
function h = adj2edgelistW(G,fname)
[i j v] = find(G);
fid = fopen(fname,'w');
fprintf(fid,'%s,%s,%s\n','Source','Target','Weight');
for k = 1:length(i)
    fprintf(fid,'%d,%d,%.4f\n',i(k),j(k),v(k));
end
fclose(fid);
end
