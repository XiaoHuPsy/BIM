function [params,logL,predicted,w]=fit_bimBins_fullModel(nC1,nC2,nI1,nI2,padding1,padding2)

% fit BIM (applied to recall tasks with discrete confidence)
% to JOL data with 2 conditions

tic;

w = [0 0];

if ~exist('padding1','var') || isempty(padding1)
    padding1 = 0;
end

if ~exist('padding2','var') || isempty(padding2)
    padding2 = 0;
end

if padding1~=0 && padding1 ~=1
   error('padding1 must be set as 0 or 1') 
end

if padding2~=0 && padding2 ~=1
   error('padding2 must be set as 0 or 1') 
end

%% warning

if sum(nC1)==0 || sum(nI1)==0
    warning('Performance for all trials in Condition 1 is the same. Estimation of parameters murec and rho is inaccurate.')
    w(1) = 1;
end

if sum(nC2)==0 || sum(nI2)==0
    warning('Performance for all trials in Condition 2 is the same. Estimation of parameters murec and rho is inaccurate.')
    w(2) = 1;
end

if sum((nC1+nI1)~=0)==1
    warning('Confidence ratings for all trials in Condition 1 are the same. Estimation of parameters Pexp and rho is inaccurate.')
    w(1) = 1;
end

if sum((nC2+nI2)~=0)==1
    warning('Confidence ratings for all trials in Condition 2 are the same. Estimation of parameters Pexp and rho is inaccurate.')
    w(2) = 1;
end

% turn off the warning for particleswarm
warning('off','globaloptim:particleswarm:initialSwarmLength');

%% padding correction for data

if padding1 == 1
    nC_padding1 = nC1 + 1/(2*length(nC1));
    nI_padding1 = nI1 + 1/(2*length(nI1));
end

if padding2 == 1
    nC_padding2 = nC2 + 1/(2*length(nC2));
    nI_padding2 = nI2 + 1/(2*length(nI2));
end

%% set up initial values
Pexp = 0.5;
Mconf = 0.5;
mu_m = 0;
rho = 0;

params = [Pexp Mconf mu_m rho];

%% settings for model fitting
% settings for fminsearch
options=optimset('TolFun',1e-10);
options=optimset(options,'TolX',1e-10);
options=optimset(options,'MaxFunEvals',10000);
options=optimset(options,'MaxIter',10000);
options=optimset(options,'Display','off');

% settings for particleswarm
options_pso = optimoptions(@particleswarm,'Display','off','InitialSwarm',[]); 
lb = [0 0 -5 -1];
ub = [1 1 5 1];
options_pso.InitialSwarm = repmat(params,[1000 1]);

%% fit the model for condition 1

% fit the model
params1 = particleswarm(@(params) bim_error_bins(params, nC1, nI1),length(params),lb,ub,options_pso);
params1 = fminsearch(@(params) bim_error_bins(params, nC1, nI1),params1,options);

% if padding1 == 1, fit the model again with padding correction
if padding1 == 1
    params1_padding = particleswarm(@(params) bim_error_bins(params, nC_padding1, nI_padding1),length(params),lb,ub,options_pso);
    params1_padding = fminsearch(@(params) bim_error_bins(params, nC_padding1, nI_padding1),params1_padding,options);
    params1(4) = params1_padding(4);
end

%% fit the model for condition 2

% fit the model
params2 = particleswarm(@(params) bim_error_bins(params, nC2, nI2),length(params),lb,ub,options_pso);
params2 = fminsearch(@(params) bim_error_bins(params, nC2, nI2),params2,options);

% if padding2 == 1, fit the model again with padding correction
if padding2 == 1
    params2_padding = particleswarm(@(params) bim_error_bins(params, nC_padding2, nI_padding2),length(params),lb,ub,options_pso);
    params2_padding = fminsearch(@(params) bim_error_bins(params, nC_padding2, nI_padding2),params2_padding,options);
    params2(4) = params2_padding(4);
end

%% warning after model fitting

% turn on the warning for particleswarm
warning('on','globaloptim:particleswarm:initialSwarmLength');

if padding1 == 0
    if abs(params1(4)) > 0.98
        warning('The estimated value of rho in Condition 1 is at edge. Consider setting padding1 = 1.')
        w(1) = 1;
    end
end

if padding2 == 0
    if abs(params2(4)) > 0.98
        warning('The estimated value of rho in Condition 2 is at edge. Consider setting padding2 = 1.')
        w(2) = 1;
    end
end

%% generate output

[err1,predicted1]=bim_error_bins(params1, nC1, nI1);
[err2,predicted2]=bim_error_bins(params2, nC2, nI2);

logL = -(err1+err2);

params = [params1 params2];

predicted = [{predicted1} {predicted2}];

toc;