function [params,logL,logLmetad,predicted]=fit_sdrm(nC,nI)

tic;

%% fit SDRM model
[params,logL,predicted]=sdrm([nI' nC']);

%% generate log likelihood in the scale of the meta-d' model
logLmetad = sdrm_error_metad(nC, nI, predicted);

%% re-organize the format of predicted proportion
predicted = [predicted(:,2) predicted(:,1)];

toc;



%% function for generating log likelihood in the scale of the meta-d' model
function logL = sdrm_error_metad(nC, nI, predicted)

pr_C = predicted(:,2);
pr_I = predicted(:,1);

pr_C = pr_C / sum(pr_C);
pr_I = pr_I / sum(pr_I);

% calculate log likelihood
logL = sum(nC.*log(pr_C')) + sum(nI.*log(pr_I'));