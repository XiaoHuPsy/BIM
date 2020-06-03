function [cv_logL,cv_logL_trial] = group_cvBIMBins_fullModel(jol_data,padding,nratings)
% cross_validation analysis for BIM (applied to recall tasks with discrete
% confidence) for a group of participants

subID = sort(unique(jol_data(:,1))); % ID for subject
conditionID = sort(unique(jol_data(:,2))); % ID for condition

nsubj = length(subID); % number of subjects

cv_logL = zeros(nsubj,1); % cross validation log likelihood
cv_logL_trial = cell(nsubj,2); % cv_logL for each trial

% start parallel pool
% delete(gcp('nocreate'));
% parpool(10);

for i = 1:nsubj
    
    jol_data_sub = jol_data(jol_data(:,1)==subID(i),:);
    jol_data_sub1 = jol_data_sub(jol_data_sub(:,2)==conditionID(1),:);
    jol_data_sub2 = jol_data_sub(jol_data_sub(:,2)==conditionID(2),:);
    
    [cv_logL(i),cv_logL1,cv_logL2] = cv_BIMBins_fullModel(jol_data_sub1(:,3:4),jol_data_sub2(:,3:4),nratings,padding(i,1),padding(i,2));
    
    cv_logL_trial(i,:) = [{cv_logL1} {cv_logL2}];
    
end