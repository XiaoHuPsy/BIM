function [data, params] = gen_SDRM_data(nratings)
% Generate data from SDRM with sigma_M and sigma_c as 0

% set random seed
ctime = datestr(now, 30);
tseed = str2num(ctime((end - 5) : end)) ;
rand('seed',tseed); 

ntrial = 500; % number of trials for each simulation
sampleNum = 1000; % number of simulations

% range for each parameter
range_cm = [-2 2];
range_rho = [-0.9 0.9];
range_conf_mean = [-2 2]; % mean of all confidence criteria
range_conf_dist = [0.1 1]; % distance between two adjacent confidence criteria

params = zeros(sampleNum,nratings+1); % true value of SDRM parameters
data = zeros(ntrial,2,sampleNum); % the whole simulation dataset

for i = 1:sampleNum
    
    % set parameter values
    cm = range_cm(1)+(range_cm(2)-range_cm(1))*rand;
    rho = range_rho(1)+(range_rho(2)-range_rho(1))*rand;
    conf_mean = range_conf_mean(1)+(range_conf_mean(2)-range_conf_mean(1))*rand;
    conf_dist = range_conf_dist(1)+(range_conf_dist(2)-range_conf_dist(1))*rand;
    
    conf = zeros(1,nratings-1);
    conf(1) = conf_mean - conf_dist*((nratings-1)/2-0.5);
    conf(2:nratings-1) = conf(1) + [1:nratings-2]*conf_dist;
    
    params(i,:) = [conf cm rho];
    
    % generate data
    [~,predicted]=sdrm_sigma0_error(params(i,:),zeros(nratings,2),3,[]);
    
    trials = mnrnd(ntrial,[predicted(:,1);predicted(:,2)]');
    
    observed_data = [];
    
    for j = 1:nratings
        observed_data = [observed_data; [j*ones(trials(j),1) zeros(trials(j),1)] ];
    end
    
    for j = (nratings+1):(nratings*2)
        observed_data = [observed_data; [(j-nratings)*ones(trials(j),1) ones(trials(j),1)] ];
    end
    
    data(:,:,i) = observed_data;
    
end