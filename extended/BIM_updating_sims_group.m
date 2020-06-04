clear;

% set random seed
ctime = datestr(now, 30);
tseed = str2num(ctime((end - 5) : end)) ;
rand('seed',tseed); 

%% setting total trial number, block number and subject number
ntrials = 100;
nblock = 4;
nsubj = 100;

%% setting parameter values

params.mu_e = 0.5;
params.mu_b = 0;
params.sigmal = 1;
params.sigmal2 = 10; % sigma_lb; set to 10 or 15 or 20

%% simulation

for i = 1: nsubj
    resultSims(i) = func_BIM_updating_sims(ntrials,nblock,params);
end

resultSims_mat = squeeze(struct2cell(resultSims));

%% output results

mu_b_trials = cell2mat(resultSims_mat(1,:));
sigma_b_trials = cell2mat(resultSims_mat(2,:));

conf = cell2mat(resultSims_mat(3,:));

meanConf_block = cell2mat(resultSims_mat(5,:));
sdConf_block = cell2mat(resultSims_mat(6,:));

%% fit restricted BIM to each block for each participant

fitted_Pexp = zeros(nblock,nsubj);
fitted_Mconf = zeros(nblock,nsubj);

ntrials_block = ntrials/nblock;

% start parallel pool
% delete(gcp('nocreate'));
% parpool(10);

for i = 1:nsubj
    for j = 1:nblock
        tmp_confData = conf((j-1)*ntrials_block+1:j*ntrials_block,i);
        tmp_fitted_params = fit_bim([tmp_confData*100 binornd(1,0.5,[ntrials_block,1])]);
        
        fitted_Pexp(j,i) = tmp_fitted_params(1);
        fitted_Mconf(j,i) = tmp_fitted_params(2);
    end
end