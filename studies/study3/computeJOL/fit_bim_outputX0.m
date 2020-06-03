function [params,logL,w,X0]=fit_bim_outputX0(observed_data,padding)
% Fit BIM to recall tasks with continuous confidence. This function can
% output the value of X0 for each trial.

tic;

w = 0;

if ~exist('padding','var') || isempty(padding)
    padding = 0;
end

if padding~=0 && padding ~=1
   error('padding must be set as 0 or 1') 
end

warning('on','all');

if length(unique(observed_data(:,1))) == 1
    warning('Confidence ratings for all trials are the same. Estimation of parameters Pexp and rho is inaccurate.')
    w = 1;
end

if length(unique(observed_data(:,2))) == 1
    warning('Performance for all trials is the same. Estimation of parameters murec and rho is inaccurate.')
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
options=optimset('TolFun',1e-10); % fminsearch 
options=optimset(options,'TolX',1e-10);
options=optimset(options,'MaxFunEvals',10000);
options=optimset(options,'MaxIter',10000);
options=optimset(options,'Display','off');

options_pso = optimoptions(@particleswarm,'Display','off','InitialSwarm',[]); 


lb = [0 0 -5 -1];
ub = [1 1 5 1];
options_pso.InitialSwarm = repmat(params,[1000 1]);


params = particleswarm(@(params) bim_error(params,observed_data),length(params),lb,ub,options_pso);
params = fminsearch(@(params) bim_error(params,observed_data),params,options);


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

%% generate output
[err,X0] = bim_error_genX0(params,observed_data);
logL = -err;

X0 = num2cell(X0');

toc;