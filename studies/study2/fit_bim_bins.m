function [params,logL,logLmetad,predicted,w]=fit_bim_bins(nC,nI,padding)

% * padding
% Add a small correction to data during model fitting when padding = 1.
% 
% We ONLY recommend setting padding = 1 when the estimated rho is at edge
% (i.e., > 0.98 or < -0.98). This can slightly improve the performance of
% parameter recovery.

tic;

w = 0;

if ~exist('padding','var') || isempty(padding)
    padding = 0;
end

if padding~=0 && padding ~=1
   error('padding must be set as 0 or 1') 
end
%% warning

if sum(nC)==0 || sum(nI)==0
    warning('Performance for all trials is the same. Estimation of parameters murec and rho is inaccurate.')
    w = 1;
end

if sum((nC+nI)~=0)==1
    warning('Confidence ratings for all trials are the same. Estimation of parameters Pexp and rho is inaccurate.')
    w = 1;
end

% turn off the warning for particleswarm
warning('off','globaloptim:particleswarm:initialSwarmLength');

%% padding correction for data

if padding == 1
    nC1 = nC + 1/(2*length(nC));
    nI1 = nI + 1/(2*length(nI));
end

%% set up initial values
Pexp = 0.5;
Mconf = 0.5;
mu_m = 0;
rho = 0;

params = [Pexp Mconf mu_m rho];

%% fit the model
% settings for fminsearch
options=optimset('TolFun',1e-6);
options=optimset(options,'TolX',1e-6);
options=optimset(options,'MaxFunEvals',100000);
options=optimset(options,'MaxIter',100000);

% settings for particleswarm
options_pso = optimoptions(@particleswarm,'Display','off','InitialSwarm',[]); 
lb = [0 0 -5 -1];
ub = [1 1 5 1];
options_pso.InitialSwarm = repmat(params,[1000 1]);

% fit the model
params = particleswarm(@(params) bim_error_bins(params, nC, nI),length(params),lb,ub,options_pso);
params = fminsearch(@(params) bim_error_bins(params, nC, nI),params,options);

% if padding == 1, fit the model again with padding correction
if padding == 1
    params1 = particleswarm(@(params) bim_error_bins(params, nC1, nI1),length(params),lb,ub,options_pso);
    params1 = fminsearch(@(params) bim_error_bins(params, nC1, nI1),params1,options);
    params(4) = params1(4);
end

% turn on the warning for particleswarm
warning('on','globaloptim:particleswarm:initialSwarmLength');

if padding == 0
    if abs(params(4)) > 0.98
        warning('The estimated value of rho is at edge. Consider setting padding = 1.')
        w = 1;
    end
end

%% generate output
[err,predicted]=bim_error_bins(params, nC, nI);

logL = -err;

%% generate log likelihood in the scale of the meta-d' model
logLmetad = bim_error_bins_metad(params, nC, nI);

toc;



%% function for generating log likelihood in the scale of the meta-d' model
function logL = bim_error_bins_metad(params, nC, nI)

[~,predicted] = bim_error_bins(params, nC, nI);

pr_C = predicted(:,1);
pr_I = predicted(:,2);

pr_C = pr_C / sum(pr_C);
pr_I = pr_I / sum(pr_I);

% calculate log likelihood
logL = sum(nC.*log(pr_C')) + sum(nI.*log(pr_I'));


%% error function for BIM
function [err,predicted] = bim_error_bins(params, nC, nI)
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

% calculate confidence criteria
nratings = length(nC);
conf_criteria = linspace(1/nratings,1-1/nratings,nratings-1);

a = 1 / (sigmal * sqrt(1+sigmal^2));
b = wavg / sqrt(1+sigmal^2);
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
    
   for ratings = 2:(nratings-1)
       
       pr_C(ratings) = mvncdf([mu_m,x0_criteria(ratings)],0,cov) - mvncdf([mu_m,x0_criteria(ratings-1)],0,cov);
       pr_I(ratings) = (normcdf(x0_criteria(ratings)) - mvncdf([mu_m,x0_criteria(ratings)],0,cov)) - (normcdf(x0_criteria(ratings-1)) - mvncdf([mu_m,x0_criteria(ratings-1)],0,cov));
       
   end
   
end

pr_C(nratings) = normcdf(mu_m) - mvncdf([mu_m,x0_criteria(nratings-1)],0,cov);
pr_I(nratings) = (1 - normcdf(x0_criteria(nratings-1))) - pr_C(nratings);

pr_C(pr_C<=0) = 1e-50;
pr_I(pr_I<=0) = 1e-50;

predicted = [pr_C' pr_I'];

% calculate log likelihood
logL = sum(nC.*log(pr_C)) + sum(nI.*log(pr_I));
err = -logL;