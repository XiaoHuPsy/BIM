% parameter recovery analysis for BIM applied to recall tasks with discrete
% confidence

clear;

nratings = 7; % total available level of confidence ratings

% set random seed
ctime = datestr(now, 30);
tseed = str2num(ctime((end - 5) : end)) ;
rand('seed',tseed); 

ntrial = 10; % number of trials for each simulation
sampleNum = 1000; % number of simulations

% range for each parameter
range_Pexp = [0.1 0.9];
range_Mconf = [0.1 0.9];
range_mu_m = [-2 2];
range_rho = [-0.9 0.9];

params = zeros(sampleNum,4); % true value of parameters
fit_params = zeros(sampleNum,4); % fitted parameters
data = cell(ntrial,2); % the whole simulation dataset

% start parallel pool
% delete(gcp('nocreate'));
% parpool(10);

% replace for loop with parfor loop when using parallel computation
for i = 1:sampleNum
    
    % set parameter value
    Pexp = range_Pexp(1)+(range_Pexp(2)-range_Pexp(1))*rand;
    Mconf = range_Mconf(1)+(range_Mconf(2)-range_Mconf(1))*rand;
    mu_m = range_mu_m(1)+(range_mu_m(2)-range_mu_m(1))*rand;
    rho = range_rho(1)+(range_rho(2)-range_rho(1))*rand;
    
    params(i,:) = [Pexp Mconf mu_m rho];
    
    % data simulation
    [~,predicted] = bim_error_bins(params(i,:), zeros(1,nratings), zeros(1,nratings));
    
    trials = mnrnd(ntrial,[predicted(:,1);predicted(:,2)]');
    
    nC = trials(1:nratings);
    nI = trials(nratings+1:end);
    
    data(i,:) = [{nC} {nI}];
    
    % model fitting
    temp1 = fit_bim_bins(nC,nI);
    
    if abs(temp1(:,4)) > 0.98 % if the estimated value of rho is at edge, use a padding correction to re-estimate the value of rho
        temp1 = fit_bim_bins(nC,nI,1);
    end
    
    fit_params(i,:) = temp1;
    
end