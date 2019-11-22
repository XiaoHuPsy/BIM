function [params,logL,logLmetad,BIC,predicted,warning_BIM] = comp3models_2conditions(conf_data,nratings)
% fit three models (BIM, SDRM, meta-d') to data from 2AFC recognition test
% (with two experimental conditions) in Study 3

if size(conf_data,2) ~= 5
   error('Please check the data format') 
end

subID = sort(unique(conf_data(:,1))); % ID of subjects
nsubj = length(subID); % number of subjects

conditionID = sort(unique(conf_data(:,2))); % ID of conditions
ncon = length(conditionID); % number of conditions

% define structures of result variables
params = struct();
params.BIM = zeros(nsubj,4,ncon);
params.SDRM = zeros(nsubj,nratings+3,ncon);
params.metad = zeros(nsubj,2*nratings-1,ncon);
params.mratio = zeros(nsubj,ncon);

logL = struct();
logL.BIM = zeros(nsubj,ncon);
logL.SDRM = zeros(nsubj,ncon);
logL.metad = zeros(nsubj,ncon);

logLmetad = struct();
logLmetad.BIM = zeros(nsubj,ncon);
logLmetad.SDRM = zeros(nsubj,ncon);
logLmetad.metad = zeros(nsubj,ncon);

BIC = struct();
BIC.BIM = zeros(nsubj,1);
BIC.SDRM = zeros(nsubj,1);
BIC.metad = zeros(nsubj,1);

predicted = struct('BIM',{{}},'SDRM',{{}},'metad',{{}});

warning_BIM = zeros(nsubj,ncon);

% convert the stimulus and response to 0 and 1
stim = sort(unique(conf_data(:,3)));
conf_data(conf_data(:,3)==stim(1),3) = 0;
conf_data(conf_data(:,3)==stim(2),3) = 1;
conf_data(conf_data(:,4)==stim(1),4) = 0;
conf_data(conf_data(:,4)==stim(2),4) = 1;

% reorganize data
for i = 1:nsubj
    
    conf_data_sub = conf_data(conf_data(:,1)==subID(i),:);
    
    ntrial{i} = 0;
    
    for j = 1:ncon
        
        conf_data_con = conf_data_sub(conf_data_sub(:,2)==conditionID(j),:);
    
        [nR_S1{i,j}, nR_S2{i,j}] = trials2counts(conf_data_con(:,3), conf_data_con(:,4), conf_data_con(:,5), nratings, 1);

        nC_S1 = rot90(nR_S1{i,j}(1:nratings),2);
        nI_S1 = nR_S1{i,j}(nratings+1:end);
        nC_S2 = nR_S2{i,j}(nratings+1:end);
        nI_S2 = rot90(nR_S2{i,j}(1:nratings),2);

        nC{i,j} = nC_S1 + nC_S2;
        nI{i,j} = nI_S1 + nI_S2;
        
        ntrial{i} = ntrial{i} + sum(nC{i,j}+nI{i,j});
    
    end
    
end

% fit BIM
for i = 1:nsubj
    for j = 1:ncon
        [params.BIM(i,:,j),logL.BIM(i,j),logLmetad.BIM(i,j),predicted.BIM{i,j},warning_BIM(i,j)] = fit_bim_bins(nC{i,j},nI{i,j});
    end
    BIC.BIM(i,1) = sum(logLmetad.BIM(i,:))*(-2)+numel(params.BIM(i,:,:))*log(ntrial{i});
end

% fit SDRM
for i = 1:nsubj
    for j = 1:ncon
        [params.SDRM(i,:,j),logL.SDRM(i,j),logLmetad.SDRM(i,j),predicted.SDRM{i,j}]=fit_sdrm(nC{i,j},nI{i,j});
    end
    BIC.SDRM(i,1) = sum(logLmetad.SDRM(i,:))*(-2)+numel(params.SDRM(i,:,:))*log(ntrial{i});
end

% fit meta-d'
for i = 1:nsubj
    for j = 1:ncon
        fit = fit_meta_d_MLE(nR_S1{i,j}, nR_S2{i,j});
        params.metad(i,:,j) = [fit.meta_da fit.t2ca_rS1 fit.t2ca_rS2];
        params.mratio(i,j) = fit.M_ratio;
        logL.metad(i,j) = fit.logL;
        logLmetad.metad(i,j) = fit.logL;
        predicted.metad{i,j} = fit;
    end
    BIC.metad(i,1) = sum(logLmetad.metad(i,:))*(-2)+numel(params.metad(i,:,:))*log(ntrial{i});
end