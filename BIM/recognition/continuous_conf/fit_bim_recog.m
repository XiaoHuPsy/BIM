function [params,logL,w,d,C] = fit_bim_recog(observed_data)

% [params,logL,w,d,C] = fit_bim_recog(observed_data)
%
% Fit BIM to data from recognition tasks with continuous confidence ratings
% on a percentage scale (i.e., a 0-100 continuous scale).
% 
% INPUTS
%
% * observed_data
% N-by-3 matrix containing data of stimulus type, Type I response and
% confidence rating in each trial. N represents the total number of trials,
% and each row represents a trial.
%
% The first column represents the true stimulus type in each trial (1 for
% S1 stimulus and 2 for S2 stimulus). The second column represents the Type
% I response in each trial (1 for S1 response and 2 for S2 response). The
% third column is the confidence rating in each trial. Confidence ratings
% should be on a continuous scale from 0 (not confident at all) to 100
% (completely confident).
%
% OUTPUTS
%
% * params
% A vector containing fitted value of the parameters in BIM (from left to
% right: Pexp, Mconf for S1 stimulus with S1 response, Mconf for S1
% stimulus with S2 response, Mconf for S2 stimulus with S1 response, Mconf
% for S2 stimulus with S2 response, rho).
%
% * logL
% Log likelihood of the data fit.
%
% * w
% w = 1 when any warning message is output. w = 0 when there is no warning
% message.
%
% * d
% Estimated value of the parameter d' in Type I signal detection theory.
%
% * C
% Estimated value of the parameter C in Type I signal detection theory.

tic;

w = 0;

% turn off the warning for particleswarm
warning('off','globaloptim:particleswarm:initialSwarmLength');

%% calculate Type I d' and C

stim = observed_data(:,1);
resp = observed_data(:,2);

HR = sum(stim==2 & resp==2)/sum(stim==2);
FAR = sum(stim==1 & resp==2)/sum(stim==1);

if HR>0.99
    HR=0.99;
elseif HR<0.01
    HR=0.01;
end

if FAR>0.99
    FAR=0.99;
elseif FAR<0.01
    FAR=0.01;
end

d = norminv(HR) - norminv(FAR);
C = (-0.5) * (norminv(HR) + norminv(FAR));

%% warning

if sum(stim==1 & resp==1) == 0
    warning('There is no S1 response in trials with S1 stimuli. Estimation of Mconf for this condition is inaccurate.')
    w = 1;
end

if sum(stim==1 & resp==2) == 0
    warning('There is no S2 response in trials with S1 stimuli. Estimation of Mconf for this condition is inaccurate.')
    w = 1;
end

if sum(stim==2 & resp==1) == 0
    warning('There is no S1 response in trials with S2 stimuli. Estimation of Mconf for this condition is inaccurate.')
    w = 1;
end

if sum(stim==2 & resp==2) == 0
    warning('There is no S2 response in trials with S2 stimuli. Estimation of Mconf for this condition is inaccurate.')
    w = 1;
end

%% set up initial values
Pexp = 0.5;
Mconf1 = 0.5;
Mconf2 = 0.5;
Mconf3 = 0.5;
Mconf4 = 0.5;
rho = 0;

params = [Pexp Mconf1 Mconf2 Mconf3 Mconf4 rho];

%% fit the model
% settings for fminsearch
options=optimset('TolFun',1e-10);
options=optimset(options,'TolX',1e-10);
options=optimset(options,'MaxFunEvals',10000);
options=optimset(options,'MaxIter',10000);
options=optimset(options,'Display','off');

% settings for particleswarm
options_pso = optimoptions(@particleswarm,'Display','off','InitialSwarm',[]); 
lb = [0 0 0 0 0 -1];
ub = [1 1 1 1 1 1];
options_pso.InitialSwarm = repmat(params,[1000 1]);

% fit the model
params = particleswarm(@(params) bim_error_recog(params,observed_data,d,C),length(params),lb,ub,options_pso);
params = fminsearch(@(params) bim_error_recog(params,observed_data,d,C),params,options);

% turn on the warning for particleswarm
warning('on','globaloptim:particleswarm:initialSwarmLength');

%% generate output
err = bim_error_recog(params,observed_data,d,C);
logL = -err;

toc;