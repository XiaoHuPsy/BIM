function [params,logL,w]=fit_bim(observed_data,padding)
% [params,logL,w]=fit_bim(observed_data,padding)
% 
% Fit BIM to data from recall tasks with continuous confidence ratings on a
% percentage scale (i.e., a 0-100 continuous scale).
% 
% INPUTS
%
% * observed_data
% N-by-2 matrix containing data of confidence ratings and recall
% performance.N represents the total number of trials, and each row
% represents a trial.The first column is confidence rating and the second
% column is recall performance in each trial.
% 
% Confidence ratings should be on a continuous scale from 0 (not confident
% at all) to 100 (completely confident). Recall performance should be 0
% (incorrect) or 1 (correct).
% 
% * padding
% Add a small correction to data during model fitting when padding = 1.
% There is no padding correction when padding = 0. Default value is 0.
% 
% We ONLY recommend setting padding = 1 when the fitted value of rho is
% at edge (i.e., > 0.98 or < -0.98) with padding = 0. This can slightly
% improve the performance of parameter recovery.
% 
% OUTPUTS
% 
% * params
% A vector containing fitted value of the parameters in BIM (from left to
% right: Pexp, Mconf, mu_m and rho)
% 
% * logL
% Log likelihood of the data fit.
% 
% * w
% w = 1 when any warning message is output. w = 0 when there is no warning
% message.

tic;

w = 0;

if ~exist('padding','var') || isempty(padding)
    padding = 0;
end

if padding~=0 && padding ~=1
   error('padding must be set as 0 or 1') 
end

if length(unique(observed_data(:,1))) == 1
    warning('Confidence ratings for all trials are the same. Estimation of parameters Pexp and rho is inaccurate.')
    w = 1;
end

if length(unique(observed_data(:,2))) == 1
    warning('Performance for all trials is the same. Estimation of parameters mu_m and rho is inaccurate.')
    w = 1;
end

% turn off the warning for particleswarm
warning('off','globaloptim:particleswarm:initialSwarmLength');

%% set up initial values
Pexp = 0.5;
Mconf = 0.5;
mu_m = 0;
rho = 0;

params = [Pexp Mconf mu_m rho];

%% fit the model
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

% fit the model
params = particleswarm(@(params) bim_error(params,observed_data),length(params),lb,ub,options_pso);
params = fminsearch(@(params) bim_error(params,observed_data),params,options);

% if padding == 1, fit the model again with padding correction
if padding == 1
    params1 = particleswarm(@(params) bim_error_padding(params,observed_data),length(params),lb,ub,options_pso);
    params1 = fminsearch(@(params) bim_error_padding(params,observed_data),params1,options);
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

%% generate log likelihood
err = bim_error(params,observed_data);
logL = -err;

toc;