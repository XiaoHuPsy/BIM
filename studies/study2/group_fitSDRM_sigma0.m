function [params,logL,predicted] = group_fitSDRM_sigma0(jol_data,nratings)
% fit SDRM (with sigma_M and sigma_c as 0) to JOL data (with 2 conditions)
% from a group of participants

subID = sort(unique(jol_data(:,1))); % ID for subject
conditionID = sort(unique(jol_data(:,2))); % ID for condition

nsubj = length(subID); % number of subjects

params = zeros(nsubj,2*(nratings+1)); % BIM parameters

logL = zeros(nsubj,1); % log likelihood

predicted = cell(nsubj,2); % model predictions

% start parallel pool
% delete(gcp('nocreate'));
% parpool(10);

for i = 1:nsubj
    
    jol_data_sub = jol_data(jol_data(:,1)==subID(i),:);
    jol_data_sub1 = jol_data_sub(jol_data_sub(:,2)==conditionID(1),:);
    jol_data_sub2 = jol_data_sub(jol_data_sub(:,2)==conditionID(2),:);
    
    % data transformation
    [nC1,nI1] = trial2countsCI(jol_data_sub1(:,3),jol_data_sub1(:,4),nratings);
    [nC2,nI2] = trial2countsCI(jol_data_sub2(:,3),jol_data_sub2(:,4),nratings);
    
    % fit sdrm
    [params(i,:),logL(i),predicted(i,:)]=fit_sdrm_sigma0(nC1,nC2,nI1,nI2);
    
end