function [err,predicted] = bim_error_bins(params, nC, nI)
% [err,predicted] = bim_error_bins(params, nC, nI)
% 
% The error function for BIM applied to recall tasks with discrete
% confidence.
% 
% Please do not run this function directly. Instead, use the function
% fit_bim_bins.

% get parameters
Pexp = params(1);
Mconf = params(2);
mu_m = params(3);
rho = params(4);

% set bound for parameters
if rho < -0.99
    err=100000;
    return
elseif rho > 0.99
    err=100000;
    return
end

if Pexp < 0.01
    err=100000;
    return    
elseif Pexp > 0.99
    err=100000;
    return 
end

if Mconf < 0.01
    err=100000;
    return    
elseif Mconf > 0.99
    err=100000;
    return 
end

if mu_m < -5
    err=100000;
    return    
elseif mu_m > 5
    err=100000;
    return 
end

% parameter transform
sigmal = sqrt(1/Pexp-1);
wavg = norminv(Mconf)*sqrt(1+sigmal^2+1/(sigmal^2));

a = 1 / (sigmal * sqrt(1+sigmal^2));
b = wavg / sqrt(1+sigmal^2);

% calculate confidence criteria
nratings = length(nC);
conf_criteria = linspace(1/nratings,1-1/nratings,nratings-1);

x0_criteria = (norminv(conf_criteria)-b)/a;

% calculate probability for each confidence category
pr_C = zeros(1,nratings);
pr_I = zeros(1,nratings);

% In the model here, (for simplicity in mathematics) we assume that a
% trial with memory strength lower than mu_m in a standard normal
% distribution can be recalled. Thus, a trial has higher memory strength if
% its strength value is lower in the model here. This is different from
% the original BIM model, in which we assume a trial can be recalled when
% it has memory strength higher than 0 in a normal distribution with mean
% of mu_m. Thus, a trial has higher memory strength if its strength value
% is higher in orginal BIM model. To accommodate this difference, we set
% the correlation parameter in the model here as the additive inverse of
% the parameter rho (i.e., (-1)*rho ).
cov = [1 -rho;-rho 1];

pr_C(1) = mvncdf([mu_m,x0_criteria(1)],0,cov);
pr_I(1) = normcdf(x0_criteria(1)) - pr_C(1);

if nratings > 2
    
    pr_C(2:(nratings-1)) = mvncdf([repmat(mu_m,[nratings-2,1]),x0_criteria(2:(nratings-1))'],0,cov)' - mvncdf([repmat(mu_m,[nratings-2,1]),x0_criteria(1:(nratings-2))'],0,cov)';
    pr_I(2:(nratings-1)) = (normcdf(x0_criteria(2:(nratings-1))) - mvncdf([repmat(mu_m,[nratings-2,1]),x0_criteria(2:(nratings-1))'],0,cov)') - (normcdf(x0_criteria(1:(nratings-2))) - mvncdf([repmat(mu_m,[nratings-2,1]),x0_criteria(1:(nratings-2))'],0,cov)');
   
end

pr_C(nratings) = normcdf(mu_m) - mvncdf([mu_m,x0_criteria(nratings-1)],0,cov);
pr_I(nratings) = (1 - normcdf(x0_criteria(nratings-1))) - pr_C(nratings);

pr_C(pr_C<=0) = 1e-50;
pr_I(pr_I<=0) = 1e-50;

predicted = [pr_C' pr_I'];

% calculate log likelihood
logL = sum(nC.*log(pr_C)) + sum(nI.*log(pr_I));
err = -logL;