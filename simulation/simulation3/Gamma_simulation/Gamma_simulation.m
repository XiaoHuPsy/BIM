% relationship between BIM parameters and Gamma correlation

clear;

% set random seed
ctime = datestr(now, 30);
tseed = str2num(ctime((end - 5) : end)) ;
rand('seed',tseed); 

% start parallel pool
% delete(gcp('nocreate'));
% parpool(10);

ntrial = 500; % number of trials for each simulation
sampleNum = 1000; % number of simulations

%nratings = 7; % available levels of confidence ratings in Likert scale

% range for each parameter
range_Pexp = [0.1 0.9];
range_Mconf = [0.1 0.9];
range_mu_m = [-2 2];
range_rho = [-0.9 0.9];

params = zeros(sampleNum,4); % true value of BIM parameters
fit_params = zeros(sampleNum,4); % fitted BIM parameters
Gamma = zeros(sampleNum,1); % Gamma correlation
data = zeros(ntrial,2,sampleNum); % the whole simulation dataset

% replace for loop with parfor loop when using parallel computation
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
    
    Gamma(i) = gammaCorr(observed_data(:,1),observed_data(:,2)); % Gamma correlation
    
end