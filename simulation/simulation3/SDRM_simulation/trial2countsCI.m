function [nC,nI] = trial2countsCI(conf,performance,nratings)

nC = zeros(1,nratings);
nI = zeros(1,nratings);

for i = 1:nratings
   nC(i) = sum(conf==i & performance==1);
   nI(i) = sum(conf==i & performance==0);
end