function [params,logL,predicted,w,d,C] = fit_bim_bins_recog(nR_S1,nR_S2)
% [params,logL,predicted,w,d,C] = fit_bim_bins_recog(nR_S1,nR_S2)

tic;

w = 0;

nratings = length(nR_S1)/2;

if nratings < 3
    error('BIM can only be applied to a confidence rating scale with no less than 3 points')
end

if length(nR_S1) ~= length(nR_S2)
    error('nR_S1 and nR_S2 must have the same length')
end

% turn off the warning for particleswarm
warning('off','globaloptim:particleswarm:initialSwarmLength');

%% calculate Type I d and C

HR = sum(nR_S2(nratings+1:end))/sum(nR_S2);
FAR = sum(nR_S1(nratings+1:end))/sum(nR_S1);

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

if sum(nR_S1(1:nratings)) == 0
    warning('There is no S1 response in S1 trials. Estimation of Mconf1 is inaccurate.')
    w = 1;
end

if sum(nR_S1(nratings+1:end)) == 0
    warning('There is no S2 response in S1 trials. Estimation of Mconf2 is inaccurate.')
    w = 1;
end

if sum(nR_S2(1:nratings)) == 0
    warning('There is no S1 response in S2 trials. Estimation of Mconf3 is inaccurate.')
    w = 1;
end

if sum(nR_S2(nratings+1:end)) == 0
    warning('There is no S2 response in S2 trials. Estimation of Mconf4 is inaccurate.')
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
params = particleswarm(@(params) bim_error_bins_recog(params,nR_S1,nR_S2,d,C),length(params),lb,ub,options_pso);
params = fminsearch(@(params) bim_error_bins_recog(params,nR_S1,nR_S2,d,C),params,options);

% turn on the warning for particleswarm
warning('on','globaloptim:particleswarm:initialSwarmLength');

%% generate output
[err,predicted] = bim_error_bins_recog(params,nR_S1,nR_S2,d,C);
logL = -err;

toc;