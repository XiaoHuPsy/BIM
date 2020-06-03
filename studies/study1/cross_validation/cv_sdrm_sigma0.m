function [cv_logL,cv_logL1,cv_logL2] = cv_sdrm_sigma0(observed_data1,observed_data2,nratings)
% cross_validation analysis for SDRM (with sigma_M and sigma_c as 0)

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
    params = fit_sdrm_sigma0(nTrialMat_tmp(1,:),nC2,nTrialMat_tmp(2,:),nI2);
    
    params1 = params(1:(nratings+1));
    
    err = sdrm_sigma0_error(params1,[leftTrialMat(2,:)' leftTrialMat(1,:)'],3,[]);
    
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
    params = fit_sdrm_sigma0(nC1,nTrialMat_tmp(1,:),nI1,nTrialMat_tmp(2,:));
    
    params2 = params((nratings+2):end);
    
    err = sdrm_sigma0_error(params2,[leftTrialMat(2,:)' leftTrialMat(1,:)'],3,[]);
    
    cv_logL2(observed_data2(:,1)==uniqueTrial(i,1) & observed_data2(:,2)==uniqueTrial(i,2)) = -err;
    
end

%% sum the log likelihood

cv_logL = sum(cv_logL1) + sum(cv_logL2);