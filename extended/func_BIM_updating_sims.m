function resultSims = func_BIM_updating_sims(ntrials,nblock,params)
% simulate data for a subject from extended BIM

%% setting parameter values

% The parameters mu_m and rho are actually not used in this simulation. The
% purpose of setting mu_m = 0 and rho = 0 is to remove the correlation
% between recall performance (or memory strength) and confidence
mu = 0;
rho = 0;

% setting mu_e, mu_b, sigmal and sigmal2
mu_e = params.mu_e;
mu_b = params.mu_b;
sigmal = params.sigmal;
sigmal2 = params.sigmal2; % sigma_lb

%% generate processing experience for each trial

exp = normrnd(mu_e,1,ntrials,1);

%% calculate mu_b and sigma_b for each trial (after updating)

sum_exp = cumsum(exp);

mu_b_trials = zeros(ntrials,1);
var_b_trials = zeros(ntrials,1);

var_b_trials(1:ntrials) = 1 ./ (1 + [1:ntrials]'./ (sigmal2^2));
sigma_b_trials = sqrt(var_b_trials);

mu_b_trials(1:ntrials) = var_b_trials .* (mu_b + sum_exp./(sigmal2^2));

%% calculate confidence rating for each trial
mu_b_previous = [mu_b; mu_b_trials(1:end-1)];
sigma_b_previous = [1; sigma_b_trials(1:end-1)];

mu_conf = (exp .* sigma_b_previous.^2 + mu_b_previous .* sigmal^2) ./ (sigma_b_previous.^2 + sigmal^2);
var_conf = sigmal^2 .* sigma_b_previous.^2 ./ (sigma_b_previous.^2+sigmal^2);
sigma_conf = sqrt(var_conf);

conf_pre = 1 - normcdf(0,mu_conf,sigma_conf);
conf = normrnd(conf_pre,0.025);

conf(conf > 1) = 1;
conf(conf < 0) = 0;

%% calculate mean and SD for reported confidence in each block

ntrials_each = ntrials/nblock;

meanConf_block = zeros(nblock,1);
sdConf_block = zeros(nblock,1);

for i = 1:nblock
    meanConf_block(i) = mean(conf( ntrials_each*(i-1)+1 : ntrials_each*i ));
    sdConf_block(i) = std(conf( ntrials_each*(i-1)+1 : ntrials_each*i ));
end

%% output

resultSims = struct;

resultSims.mu_b_trials = mu_b_trials;
resultSims.sigma_b_trials = sigma_b_trials;
resultSims.conf = conf;
resultSims.conf_pre = conf_pre;
resultSims.meanConf_block = meanConf_block;
resultSims.sdConf_block = sdConf_block;
