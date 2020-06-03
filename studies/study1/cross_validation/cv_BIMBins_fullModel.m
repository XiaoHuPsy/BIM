function [cv_logL,cv_logL1,cv_logL2] = cv_BIMBins_fullModel(observed_data1,observed_data2,nratings,padding1,padding2)
% cross_validation analysis for BIM applied to recall tasks with discrete confidence

if ~exist('padding1','var') || isempty(padding1)
    padding1 = 0;
end

if ~exist('padding2','var') || isempty(padding2)
    padding2 = 0;
end

if padding1~=0 && padding1 ~=1
   error('padding1 must be set as 0 or 1') 
end

if padding2~=0 && padding2 ~=1
   error('padding2 must be set as 0 or 1') 
end

%% define variables
ntrial1 = size(observed_data1,1);
ntrial2 = size(observed_data2,1);

cv_logL1 = zeros(ntrial1,1);
cv_logL2 = zeros(ntrial2,1);

%% data transformation
[nC1,nI1] = trial2countsCI(observed_data1(:,1),observed_data1(:,2),nratings);
[nC2,nI2] = trial2countsCI(observed_data2(:,1),observed_data2(:,2),nratings);

% start parallel pool
% delete(gcp('nocreate'));
% parpool(10);

%% LOO cross validation for trials in condition 1

nTrialMat = [nC1;nI1];

uniqueTrial = unique(observed_data1,'rows');

for i = 1:size(uniqueTrial,1)
    
    % remove a trial
    nTrialMat_tmp = nTrialMat;
    nTrialMat_tmp(2-uniqueTrial(i,2),uniqueTrial(i,1)) = nTrialMat_tmp(2-uniqueTrial(i,2),uniqueTrial(i,1)) - 1;
    
    % the left trial
    leftTrialMat = zeros(size(nTrialMat_tmp));
    leftTrialMat(2-uniqueTrial(i,2),uniqueTrial(i,1)) = leftTrialMat(2-uniqueTrial(i,2),uniqueTrial(i,1)) + 1;
    
    % model fitting with training data
    params = fit_bimBins_fullModel(nTrialMat_tmp(1,:),nC2,nTrialMat_tmp(2,:),nI2,padding1,padding2);
    
    params1 = params(1:4);
    
    err = bim_error_bins(params1,leftTrialMat(1,:),leftTrialMat(2,:));
    
    cv_logL1(observed_data1(:,1)==uniqueTrial(i,1) & observed_data1(:,2)==uniqueTrial(i,2)) = -err;
    
end

%% LOO cross validation for trials in condition 2

nTrialMat = [nC2;nI2];

uniqueTrial = unique(observed_data2,'rows');

for i = 1:size(uniqueTrial,1)
    
    % remove a trial
    nTrialMat_tmp = nTrialMat;
    nTrialMat_tmp(2-uniqueTrial(i,2),uniqueTrial(i,1)) = nTrialMat_tmp(2-uniqueTrial(i,2),uniqueTrial(i,1)) - 1;
    
    % the left trial
    leftTrialMat = zeros(size(nTrialMat_tmp));
    leftTrialMat(2-uniqueTrial(i,2),uniqueTrial(i,1)) = leftTrialMat(2-uniqueTrial(i,2),uniqueTrial(i,1)) + 1;
    
    % model fitting with training data
    params = fit_bimBins_fullModel(nC1,nTrialMat_tmp(1,:),nI1,nTrialMat_tmp(2,:),padding1,padding2);
    
    params2 = params(5:8);
    
    err = bim_error_bins(params2,leftTrialMat(1,:),leftTrialMat(2,:));
    
    cv_logL2(observed_data2(:,1)==uniqueTrial(i,1) & observed_data2(:,2)==uniqueTrial(i,2)) = -err;
    
end

%% sum the log likelihood

cv_logL = sum(cv_logL1) + sum(cv_logL2);