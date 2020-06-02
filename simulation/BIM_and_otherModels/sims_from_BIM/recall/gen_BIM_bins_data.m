function [data, params] = gen_BIM_bins_data(nratings)
% generate data from BIM applied to recall tasks with discrete confidence

% set random seed
ctime = datestr(now, 30);
tseed = str2num(ctime((end - 5) : end)) ;
rand('seed',tseed); 

ntrial = 500; % number of trials for each simulation
sampleNum = 1000; % number of simulations

% range for each parameter
range_Pexp = [0.1 0.9];
range_Mconf = [0.1 0.9];
range_mu_m = [-2 2];
range_rho = [-0.9 0.9];

params = zeros(sampleNum,4); % true value of parameters
data = zeros(ntrial,2,sampleNum); % the whole simulation dataset

for i = 1:sampleNum
    
    % set parameter value
    Pexp = range_Pexp(1)+(range_Pexp(2)-range_Pexp(1))*rand;
    Mconf = range_Mconf(1)+(range_Mconf(2)-range_Mconf(1))*rand;
    mu_m = range_mu_m(1)+(range_mu_m(2)-range_mu_m(1))*rand;
    rho = range_rho(1)+(range_rho(2)-range_rho(1))*rand;
    
    params(i,:) = [Pexp Mconf mu_m rho];
    
    % generate data
    [~,predicted] = bim_error_bins(params(i,:), zeros(1,nratings), zeros(1,nratings));
    
    trials = mnrnd(ntrial,[predicted(:,1);predicted(:,2)]');
    
    observed_data = [];
    
    for j = 1:nratings
        observed_data = [observed_data; [j*ones(trials(j),1) ones(trials(j),1)] ];
    end
    
    for j = (nratings+1):(nratings*2)
        observed_data = [observed_data; [(j-nratings)*ones(trials(j),1) zeros(trials(j),1)] ];
    end
    
    data(:,:,i) = observed_data;
    
end