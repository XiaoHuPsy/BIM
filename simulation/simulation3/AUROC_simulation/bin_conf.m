function conf = bin_conf(conf,minconf,maxconf,nratings)
% Divide continous confidence ratings into bins

scale = linspace(minconf,maxconf,nratings+1);
scale = scale(2:end-1);

for i=1:length(conf)
    
    scale1 = sort([scale conf(i)]);
    conf(i) = find(scale1==conf(i));
    
end