function [params,logL,logLmetad,BIC,predicted,warning_BIM] = comp3models_1condition(conf_data,nratings)
% fit three models (BIM, SDRM, meta-d') to data from 2AFC recognition test
% (with only one experimental condition) in Study 3

if size(conf_data,2) ~= 4
   error('Please check the data format') 
end

subID = sort(unique(conf_data(:,1))); % ID of subjects
nsubj = length(subID); % number of subjects

% define structures of result variables
params = struct();
params.BIM = zeros(nsubj,4);
params.SDRM = zeros(nsubj,nratings+3);
params.metad = zeros(nsubj,2*nratings-1);
params.mratio = zeros(nsubj,1);

logL = struct();
logL.BIM = zeros(nsubj,1);
logL.SDRM = zeros(nsubj,1);
logL.metad = zeros(nsubj,1);

logLmetad = struct();
logLmetad.BIM = zeros(nsubj,1);
logLmetad.SDRM = zeros(nsubj,1);
logLmetad.metad = zeros(nsubj,1);

BIC = struct();
BIC.BIM = zeros(nsubj,1);
BIC.SDRM = zeros(nsubj,1);
BIC.metad = zeros(nsubj,1);

predicted = struct('BIM',{{}},'SDRM',{{}},'metad',{{}});

warning_BIM = zeros(nsubj,1);

% convert the stimulus and response to 0 and 1
stim = sort(unique(conf_data(:,2)));
conf_data(conf_data(:,2)==stim(1),2) = 0;
conf_data(conf_data(:,2)==stim(2),2) = 1;
conf_data(conf_data(:,3)==stim(1),3) = 0;
conf_data(conf_data(:,3)==stim(2),3) = 1;

% reorganize data
for i = 1:nsubj
    
    conf_data_sub = conf_data(conf_data(:,1)==subID(i),:);
    [nR_S1{i}, nR_S2{i}] = trials2counts(conf_data_sub(:,2), conf_data_sub(:,3), conf_data_sub(:,4), nratings, 1);
    
    nC_S1 = rot90(nR_S1{i}(1:nratings),2);
    nI_S1 = nR_S1{i}(nratings+1:end);
    nC_S2 = nR_S2{i}(nratings+1:end);
    nI_S2 = rot90(nR_S2{i}(1:nratings),2);
    
    nC{i} = nC_S1 + nC_S2;
    nI{i} = nI_S1 + nI_S2;
    
end

% fit BIM
for i = 1:nsubj
    [params.BIM(i,:),logL.BIM(i,1),logLmetad.BIM(i,1),predicted.BIM{i,1},warning_BIM(i,1)] = fit_bim_bins(nC{i},nI{i});
    BIC.BIM(i,1) = logLmetad.BIM(i,1)*(-2)+length(params.BIM(i,:))*log(sum(nC{i}+nI{i}));
end

% fit SDRM
for i = 1:nsubj
    [params.SDRM(i,:),logL.SDRM(i,1),logLmetad.SDRM(i,1),predicted.SDRM{i,1}]=fit_sdrm(nC{i},nI{i});
    BIC.SDRM(i,1) = logLmetad.SDRM(i,1)*(-2)+length(params.SDRM(i,:))*log(sum(nC{i}+nI{i}));
end

% fit meta-d' model
for i = 1:nsubj
    fit = fit_meta_d_MLE(nR_S1{i}, nR_S2{i});
    params.metad(i,:) = [fit.meta_da fit.t2ca_rS1 fit.t2ca_rS2];
    params.mratio(i,1) = fit.M_ratio;
    logL.metad(i,1) = fit.logL;
    logLmetad.metad(i,1) = fit.logL;
    BIC.metad(i,1) = logLmetad.metad(i,1)*(-2)+length(params.metad(i,:))*log(sum(nR_S1{i}+nR_S2{i}));
    predicted.metad{i,1} = fit;
end