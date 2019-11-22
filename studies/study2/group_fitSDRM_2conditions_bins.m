function [params,logL,predicted] = group_fitSDRM_2conditions_bins(jol_data,nratings)
% First divide JOLs into several bins, and then fit SDRM to JOL data (with 2
% conditions) from a group of participants

nparams = nratings+3; % nunber of parameters

subID = sort(unique(jol_data(:,1))); % ID for subject
conditionID = sort(unique(jol_data(:,2))); % ID for condition

nsubj = length(subID); % number of subjects

params1 = zeros(nsubj,nparams); % fitted parameters in condition 1
params2 = zeros(nsubj,nparams); % fitted parameters in condition 2
logL = zeros(nsubj,2); % log likelihood

predicted = {};

for i = 1:nsubj
    
    jol_data_sub = jol_data(jol_data(:,1)==subID(i),:);
    jol_data_sub1 = jol_data_sub(jol_data_sub(:,2)==conditionID(1),:);
    jol_data_sub2 = jol_data_sub(jol_data_sub(:,2)==conditionID(2),:);
    
    jol_data_sub1(:,3) = bin_conf(jol_data_sub1(:,3),0,100,nratings);
    jol_data_sub2(:,3) = bin_conf(jol_data_sub2(:,3),0,100,nratings);
    
    [nC,nI] = trial2countsCI(jol_data_sub1(:,3),jol_data_sub1(:,4),nratings);    
    [params1(i,:),logL(i,1),~,predicted{i,1}]=fit_sdrm(nC,nI);
    
    [nC,nI] = trial2countsCI(jol_data_sub2(:,3),jol_data_sub2(:,4),nratings);    
    [params2(i,:),logL(i,2),~,predicted{i,2}]=fit_sdrm(nC,nI);
    
end

params{1} = params1;
params{2} = params2;