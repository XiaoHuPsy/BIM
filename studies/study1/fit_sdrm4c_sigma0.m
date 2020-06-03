function [params,logL,predicted]=fit_sdrm4c_sigma0(nC1,nC2,nI1,nI2)
% fit Model 4c of SDRM (with sigma_M and sigma_c as 0) to JOL data with 2 conditions

tic;

%% fit SDRM model
[params,logL,predicted1,predicted2]=sdrm4c_sigma0([nI1' nC1'],[nI2' nC2']);

%% re-organize the format of predicted proportion
predicted1 = [predicted1(:,2) predicted1(:,1)];
predicted2 = [predicted2(:,2) predicted2(:,1)];

%% generate output
predicted = [{predicted1} {predicted2}];

toc;