function gamma = gammaCorr(x1,x2)
% compute gamma correlation between two vectors

if length(size(x1))==2 && size(x1,2)==1
    x1 = x1';
end

if length(size(x2))==2 && size(x2,2)==1
    x2 = x2';
end

pairs = combvec([x1;x2],[x1;x2]);

concor = sum(((pairs(1,:)-pairs(3,:)).*(pairs(2,:)-pairs(4,:))) > 0);
discor = sum(((pairs(1,:)-pairs(3,:)).*(pairs(2,:)-pairs(4,:))) < 0);

gamma = (concor-discor)/(concor+discor);