function [params,logL,predicted]=fit_sdrm_sigma0(nC1,nC2,nI1,nI2)
% fit SDRM (with sigma_M and sigma_c as 0) to JOL data with 2 conditions

tic;

%% fit SDRM model
[params1,logL1,predicted1]=sdrm_sigma0([nI1' nC1']);
[params2,logL2,predicted2]=sdrm_sigma0([nI2' nC2']);

%% re-organize the format of predicted proportion
predicted1 = [predicted1(:,2) predicted1(:,1)];
predicted2 = [predicted2(:,2) predicted2(:,1)];

%% generate output
logL = logL1 + logL2;
params = [params1 params2];
predicted = [{predicted1} {predicted2}];

toc;