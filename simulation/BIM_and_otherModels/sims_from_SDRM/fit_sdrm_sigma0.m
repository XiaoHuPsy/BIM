function [params,logL,predicted]=fit_sdrm_sigma0(nC1,nI1)
% fit SDRM (with sigma_M and sigma_c as 0) to data

tic;

%% fit SDRM model
[params,logL,predicted]=sdrm_sigma0([nI1' nC1']);

%% re-organize the format of predicted proportion
predicted = [predicted(:,2) predicted(:,1)];

toc;