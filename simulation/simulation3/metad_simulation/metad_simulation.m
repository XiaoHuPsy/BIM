% relationship between parameters in BIM and SDRM

clear;

% set random seed
ctime = datestr(now, 30);
tseed = str2num(ctime((end - 5) : end)) ;
rand('seed',tseed); 

ntrial = 500; % number of trials for each simulation
sampleNum = 1000; % number of simulations

nratings = 7; % available levels of confidence ratings in Likert scale

% range for each parameter
range_Pexp = [0.1 0.9];
range_Mconf = [0.1 0.9];
range_mu_m = [-2 2];
range_rho = [-0.9 0.9];

params = zeros(sampleNum,4); % true value of BIM parameters
fit_params = zeros(sampleNum,4); % fitted BIM parameters
fit_params_Metad = zeros(sampleNum,2*nratings+1); % fitted parameters in the meta-d' model
data = zeros(ntrial,2,sampleNum); % the whole simulation dataset

fit = {};

for i = 1:sampleNum
    
    Pexp = range_Pexp(1)+(range_Pexp(2)-range_Pexp(1))*rand;
    Mconf = range_Mconf(1)+(range_Mconf(2)-range_Mconf(1))*rand;
    mu_m = range_mu_m(1)+(range_mu_m(2)-range_mu_m(1))*rand;
    rho = range_rho(1)+(range_rho(2)-range_rho(1))*rand;
    
    params(i,:) = [Pexp Mconf mu_m rho];
    
    observed_data = BIM_simulation(Pexp,Mconf,mu_m,rho,ntrial);
    
    data(:,:,i) = observed_data;
    
    temp1 = fit_bim(observed_data);

    if abs(temp1(:,4)) > 0.98 % if the estimated value of rho is at edge, use a padding correction to re-estimate the value of rho
        temp1 = fit_bim(observed_data,1);
    end
    
    fit_params(i,:) = temp1;
    
    observed_data(:,1) = bin_conf(observed_data(:,1),0,100,nratings); % divide confidence ratings into bins
    
    % generate stimulus type for each trial
    stim = [ones(1,ntrial/2) zeros(1,ntrial/2)];
    stim = stim(randperm(length(stim)));
    
    % generate response for each trial
    response = stim;
    response(observed_data(:,2)'==0) = 1-response(observed_data(:,2)'==0);
    
    % fit the meta-d' model
    [nR_S1, nR_S2] = trials2counts(stim, response, observed_data(:,1)', nratings, 1);
    fit{i,1} = fit_meta_d_MLE(nR_S1, nR_S2);
    fit_params_Metad(i,:) = [fit{i,1}.da fit{i,1}.meta_da fit{i,1}.M_ratio fit{i,1}.t2ca_rS1 fit{i,1}.t2ca_rS2];
    
end