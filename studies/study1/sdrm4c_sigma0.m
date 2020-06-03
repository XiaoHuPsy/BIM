function [params,err,predicted1,predicted2]=sdrm4c_sigma0(observed1,observed2)
% Function for Model 4c of SDRM with sigma_M and sigma_c as 0.

% pass to this function a n X 2 matrix of observed frequency values
% the first column is not recalled confidence
% the second column is recalled confidence

% here is an example dataset that could be passed for immediate JOLs
% without prior test experience
% observed = [113 25; 248 72; 159 90; 105 73; 80 56; 27 32]

% here is an example dataset that could be passed for delayed JOLs without
% prior test experience
% observed = [433 9; 154 31; 51 53; 20 69; 7 47; 11 195]

% here is an example dataset that could be passed for immediate JOLs with
% prior test experience (condition SJTSJT in the Psych Review paper)
% observed = [163 42; 132 111; 62 105; 33 105; 15 116; 11 185]

% after enter the observed data type the following command
% [params,err,predicted]=sdrm(observed)

% here is the list of free parameters
    % conf = list of confidence criteria
    % cm = memory criterion
    % sc = standard deviation of confidence criteria
    % sm = standard deviation of memory criteria
    % rho = correlation between confidence and memory
    
% turn off the warning for particleswarm
warning('off','globaloptim:particleswarm:initialSwarmLength');

n=size(observed1,1); % number of confidence levels
for i=1:n-1    % set up initial values for confidence criteria
    conf(i)=-1.5+(i-1)*(3/(n-2));
end
% set up initial values for other parameters
beta=1;
cm1=0.0;
cm2=0.0;
rho1=0.8;
rho2=0.8;

options=optimset('TolFun',1e-10); % fminsearch 
options=optimset(options,'TolX',1e-10);
options=optimset(options,'MaxFunEvals',10000);
options=optimset(options,'MaxIter',10000);

which_run=1; % fit only the confidence parameters
set_params=[rho1 rho2]; 
params=[conf beta cm1 cm2]; 

options_pso = optimoptions(@particleswarm,'Display','off','InitialSwarm',[]); 
lb = [-1e5*ones(1,length(conf)) 0 -1e5 -1e5];
ub = [1e5*ones(1,length(conf)) 1e5 1e5 1e5];
options_pso.InitialSwarm = repmat(params,[1000 1]);

params = particleswarm(@(params) sdrm4c_sigma0_error(params,observed1,observed2,which_run,set_params),length(params),lb,ub,options_pso);
params = fminsearch(@(params) sdrm4c_sigma0_error(params,observed1,observed2,which_run,set_params),params,options);

which_run=2; % fit only the sensitivity parameters
set_params=params; 
params=[rho1 rho2]; 

params = fminsearch(@(params) sdrm4c_sigma0_error(params,observed1,observed2,which_run,set_params),params,options);

which_run=3; % using best parameters from 1 and 2, fit all parameters
params=[set_params params]; 

options_pso = optimoptions(@particleswarm,'Display','off','InitialSwarm',[]); 
lb = [-1e5*ones(1,length(conf)) 0 -1e5 -1e5 -1 -1];
ub = [1e5*ones(1,length(conf)) 1e5 1e5 1e5 1 1];
options_pso.InitialSwarm = repmat(params,[1000 1]);

params = particleswarm(@(params) sdrm4c_sigma0_error(params,observed1,observed2,which_run,set_params),length(params),lb,ub,options_pso);
params = fminsearch(@(params) sdrm4c_sigma0_error(params,observed1,observed2,which_run,set_params),params,options);

[err,predicted1,predicted2]=sdrm4c_sigma0_error(params,observed1,observed2,which_run,set_params); % get predicted values
err=-err; % convert negative log likelihood back to log likelihood

% turn on the warning for particleswarm
warning('on','globaloptim:particleswarm:initialSwarmLength');

end