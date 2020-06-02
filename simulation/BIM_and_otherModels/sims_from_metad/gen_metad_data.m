function [data, data_nR, params] = gen_metad_data(nratings)
% Generate data from the meta-d' model

% set random seed
ctime = datestr(now, 30);
tseed = str2num(ctime((end - 5) : end)) ;
rand('seed',tseed); 

ntrial = 500; % number of trials for each simulation
sampleNum = 1000; % number of simulations

% range for each parameter
range_d = [-3 3];
range_metad = [-3 3];
range_confS1_max = [-1 0]; % max confidence criteria for S1
range_confS1_fullDist = [0.2 3]; % distance between smallest and largest confidence criteria for S1

c1 = 0; % type I criteria

params = zeros(sampleNum,2*nratings); % true value of SDRM parameters
data = zeros(ntrial,2,sampleNum); % the whole simulation dataset
data_nR = cell(sampleNum,2); % the whole simulation dataset in nR format

for i = 1:sampleNum
    
    d = range_d(1)+(range_d(2)-range_d(1))*rand;
    metad = range_metad(1)+(range_metad(2)-range_metad(1))*rand;
    
    % generate conf criteria for S1
    confS1_max = range_confS1_max(1)+(range_confS1_max(2)-range_confS1_max(1))*rand;
    confS1_fullDist = range_confS1_fullDist(1)+(range_confS1_fullDist(2)-range_confS1_fullDist(1))*rand;
    
    confS1_dist = confS1_fullDist/(nratings-2);
    
    confS1 = zeros(1,nratings-1);
    confS1(1) = confS1_max;
    confS1(2:nratings-1) = confS1(1) - [1:nratings-2]*confS1_dist;
    
    confS1 = rot90(confS1,2);
    
    % generate conf criteria for S2
    confS2_min = (-1)*(range_confS1_max(1)+(range_confS1_max(2)-range_confS1_max(1))*rand);
    confS2_fullDist = range_confS1_fullDist(1)+(range_confS1_fullDist(2)-range_confS1_fullDist(1))*rand;
    
    confS2_dist = confS2_fullDist/(nratings-2);
    
    confS2 = zeros(1,nratings-1);
    confS2(1) = confS2_min;
    confS2(2:nratings-1) = confS2(1) + [1:nratings-2]*confS2_dist;
    
    params(i,:) = [d metad confS1 confS2];
    
    % generate data
    sim = metad_sim(d, metad, c1, confS1, confS2, ntrial);
    
    data_nR(i,:) = [{sim.nR_S1} {sim.nR_S2}];
    
    nC_rS1 = rot90(sim.nR_S1(1:nratings),2);
    nI_rS1 = rot90(sim.nR_S2(1:nratings),2);
    nC_rS2 = sim.nR_S2(nratings+1:end);
    nI_rS2 = sim.nR_S1(nratings+1:end);
    nC = nC_rS1 + nC_rS2;
    nI = nI_rS1 + nI_rS2;
    
    observed_data = [];
    
    for j = 1:nratings
        observed_data = [observed_data; [j*ones(nC(j),1) ones(nC(j),1)]; [j*ones(nI(j),1) zeros(nI(j),1)]];
    end
    
    data(:,:,i) = observed_data;
    
end