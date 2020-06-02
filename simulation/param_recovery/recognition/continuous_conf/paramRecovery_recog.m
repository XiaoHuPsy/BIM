% parameter recovery analysis for BIM applied to recognition tasks with
% continuous confidence

clear;

% set random seed
ctime = datestr(now, 30);
tseed = str2num(ctime((end - 5) : end)) ;
rand('seed',tseed); 

% start parallel pool
% delete(gcp('nocreate'));
% parpool(10);

ntrial = 10; % number of trials for each simulation
sampleNum = 1000; % number of simulations

% range for each parameter
range_Pexp = [0.1 0.9];
range_Mconf1 = [0.1 0.9];
range_Mconf2 = [0.1 0.9];
range_Mconf3 = [0.1 0.9];
range_Mconf4 = [0.1 0.9];
range_rho = [-0.9 0.9];

range_d = [-3 3];
range_C = [-1 1];

params = zeros(sampleNum,8); % true value of parameters
fit_params = zeros(sampleNum,8); % fitted parameters
data = zeros(ntrial,3,sampleNum); % the whole simulation dataset

% replace for loop with parfor loop when using parallel computation
for i = 1:sampleNum
    
    % set parameter value
    Pexp = range_Pexp(1)+(range_Pexp(2)-range_Pexp(1))*rand;
    Mconf1 = range_Mconf1(1)+(range_Mconf1(2)-range_Mconf1(1))*rand;
    Mconf2 = range_Mconf2(1)+(range_Mconf2(2)-range_Mconf2(1))*rand;
    Mconf3 = range_Mconf3(1)+(range_Mconf3(2)-range_Mconf3(1))*rand;
    Mconf4 = range_Mconf4(1)+(range_Mconf4(2)-range_Mconf4(1))*rand;
    rho = range_rho(1)+(range_rho(2)-range_rho(1))*rand;
    
    d = range_d(1)+(range_d(2)-range_d(1))*rand;
    C = range_C(1)+(range_C(2)-range_C(1))*rand;
    
    params(i,:) = [Pexp Mconf1 Mconf2 Mconf3 Mconf4 rho d C];
    
    % generate data
    observed_data = BIM_simulation_recog(Pexp,Mconf1,Mconf2,Mconf3,Mconf4,rho,d,C,ntrial);
    
    data(:,:,i) = observed_data;
    
    % model fitting
    [temp1,~,~,d,C] = fit_bim_recog(observed_data);
    
    fit_params(i,:) = [temp1 d C];
    
end