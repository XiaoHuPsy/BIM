function [params,logL,predicted,w]=fit_bim_bins(nC,nI,padding)
% [params,logL,predicted,w]=fit_bim_bins(nC,nI,padding)
% 
% Fit BIM to data from recall tasks with confidence ratings on a discrete
% scale.
% 
% INPUTS
% 
% * nC, nI
% nC is a 1-by-M vector containing the number of correctly answered trials
% (i.e., recalled trials) in each level of confidence ratings. nI is a
% 1-by-M vector containing the number of incorrectly answered trials (i.e.,
% unrecalled trials) in each level of confidence ratings. M represents the
% total available level of confidence ratings. For example, if subject can
% rate confidence on a scale of 1-4, then M = 4. PLEASE NOTE: BIM requires
% M to be no less than 3.
%
% e.g., if nC = [11 15 31 56], and nI = [44 37 25 8], then the subject had
% the following response counts:
% correctly answered, confidence = 1 : 11 trials
% correctly answered, confidence = 2 : 15 trials
% correctly answered, confidence = 3 : 31 trials
% correctly answered, confidence = 4 : 56 trials
% incorrectly answered, confidence = 1 : 44 trials
% incorrectly answered, confidence = 2 : 37 trials
% incorrectly answered, confidence = 3 : 25 trials
% incorrectly answered, confidence = 4 : 8 trials
%
% Use the function trial2countsCI to generate nC and nI from raw data.
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
% * predicted
% An M-by-2 matrix containing model prediction about the proportion of
% correctly and incorrectly answered trials in each level of confidence
% ratings. M represents the total available level of confidence ratings.
% Each row in this matrix represents a confidence level (from 1 to M). The
% first column represents the proportion for correctly answered trials and
% the second column represents the proportion for incorrectly answered
% trials. All of the elements in this matrix sum to 1.
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

if length(nC) < 3 || length(nI) < 3
    error('BIM can only be applied to a confidence rating scale with no less than 3 points')
end

if length(nC) ~= length(nI)
    error('nC and nI must have the same length')
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

toc;