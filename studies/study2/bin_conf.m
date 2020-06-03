function conf = bin_conf(conf,minconf,maxconf,nratings)
% conf = bin_conf(conf,minconf,maxconf,nratings)
%
% Divide continous confidence ratings into several bins.
%
% INPUTS
%
% * conf
% A vector containing confidence ratings on a continuous scale.
%
% * minconf
% Minimum value of confidence rating on the continuous scale.
%
% * maxconf
% Maximum value of confidence rating on the continuous scale.
%
% * nratings
% Total available level of confidence ratings for the discrete scale.
%
% OUTPUTS
%
% * conf
% Transformed confidence ratings on the discrete scale.

scale = linspace(minconf,maxconf,nratings+1);
scale = scale(2:end-1);

for i=1:length(conf)
    
    scale1 = sort([scale conf(i)]);
    conf(i) = find(scale1==conf(i));
    
end