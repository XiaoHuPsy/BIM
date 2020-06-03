function [params,logL,w]=fit_bim_fullModel(observed_data1,observed_data2,padding1,padding2)

% fit BIM (applied to recall tasks with continuous confidence)
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

if length(unique(observed_data1(:,1))) == 1
    warning('Confidence ratings for all trials in Condition 1 are the same. Estimation of parameters Pexp and rho is inaccurate.')
    w(1) = 1;
end

if length(unique(observed_data2(:,1))) == 1
    warning('Confidence ratings for all trials in Condition 2 are the same. Estimation of parameters Pexp and rho is inaccurate.')
    w(2) = 1;
end

if length(unique(observed_data1(:,2))) == 1
    warning('Performance for all trials in Condition 1 is the same. Estimation of parameters mu_m and rho is inaccurate.')
    w(1) = 1;
end

if length(unique(observed_data2(:,2))) == 1
    warning('Performance for all trials in Condition 2 is the same. Estimation of parameters mu_m and rho is inaccurate.')
    w(2) = 1;
end

% turn off the warning for particleswarm
warning('off','globaloptim:particleswarm:initialSwarmLength');

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
params1 = particleswarm(@(params) bim_error(params,observed_data1),length(params),lb,ub,options_pso);
params1 = fminsearch(@(params) bim_error(params,observed_data1),params1,options);

% if padding1 == 1, fit the model again with padding correction
if padding1 == 1
    params1_padding = particleswarm(@(params) bim_error_padding(params,observed_data1),length(params),lb,ub,options_pso);
    params1_padding = fminsearch(@(params) bim_error_padding(params,observed_data1),params1_padding,options);
    params1(4) = params1_padding(4);
end

%% fit the model for condition 2

% fit the model
params2 = particleswarm(@(params) bim_error(params,observed_data2),length(params),lb,ub,options_pso);
params2 = fminsearch(@(params) bim_error(params,observed_data2),params2,options);

% if padding2 == 1, fit the model again with padding correction
if padding2 == 1
    params2_padding = particleswarm(@(params) bim_error_padding(params,observed_data2),length(params),lb,ub,options_pso);
    params2_padding = fminsearch(@(params) bim_error_padding(params,observed_data2),params2_padding,options);
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

err1 = bim_error(params1,observed_data1);
err2 = bim_error(params2,observed_data2);

logL = -(err1+err2);

params = [params1 params2];

toc;