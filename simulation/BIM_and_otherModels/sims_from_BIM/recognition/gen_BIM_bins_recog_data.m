function [data_nR, params] = gen_BIM_bins_recog_data(nratings)
% generate data from BIM applied to recognition tasks with discrete confidence

% set random seed
ctime = datestr(now, 30);
tseed = str2num(ctime((end - 5) : end)) ;
rand('seed',tseed); 

ntrial = 500; % number of trials for each simulation
sampleNum = 1000; % number of simulations

% range for each parameter
range_Pexp = [0.1 0.9];
range_Mconf1 = [0.1 0.9]; % Mconf for S1 stimulus with S1 response
range_Mconf2 = [0.1 0.9]; % Mconf for S1 stimulus with S2 response
range_Mconf3 = [0.1 0.9]; % Mconf for S2 stimulus with S1 response
range_Mconf4 = [0.1 0.9]; % Mconf for S2 stimulus with S2 response
range_rho = [-0.9 0.9];

range_d = [-3 3];
range_C = [-1 1];

params = zeros(sampleNum,8); % true value of parameters
data_nR = cell(sampleNum,2); % the whole simulation dataset

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
    [~,predicted] = bim_error_bins_recog([Pexp Mconf1 Mconf2 Mconf3 Mconf4 rho],zeros(1,nratings*2),zeros(1,nratings*2),d,C);
    
    nR_S1 = mnrnd(ntrial/2,predicted.S1);
    nR_S2 = mnrnd(ntrial/2,predicted.S2);
    
    data_nR(i,:) = [{nR_S1} {nR_S2}];
    
end