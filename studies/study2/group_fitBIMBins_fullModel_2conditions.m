function [params,logL,predicted,warning,padding] = group_fitBIMBins_fullModel_2conditions(jol_data,nratings)
% fit BIM (applied to recall tasks with discrete confidence)
% to JOL data (with 2 conditions) from a group of participants

subID = sort(unique(jol_data(:,1))); % ID for subject
conditionID = sort(unique(jol_data(:,2))); % ID for condition

nsubj = length(subID); % number of subjects

params1 = zeros(nsubj,4); % fitted parameters in condition 1
params2 = zeros(nsubj,4); % fitted parameters in condition 2
logL = zeros(nsubj,1);
warning = zeros(nsubj,2);

predicted = cell(nsubj,2);

padding1 = zeros(nsubj,1); % whether padding correction is implemented in condition 1
padding2 = zeros(nsubj,1); % whether padding correction is implemented in condition 2

for i = 1:nsubj
    
    jol_data_sub = jol_data(jol_data(:,1)==subID(i),:);
    jol_data_sub1 = jol_data_sub(jol_data_sub(:,2)==conditionID(1),:);
    jol_data_sub2 = jol_data_sub(jol_data_sub(:,2)==conditionID(2),:);
    
    [nC1,nI1] = trial2countsCI(jol_data_sub1(:,3),jol_data_sub1(:,4),nratings);
    [nC2,nI2] = trial2countsCI(jol_data_sub2(:,3),jol_data_sub2(:,4),nratings);
    
    [params_tmp,logL(i,1),predicted(i,:),warning(i,:)]=fit_bimBins_fullModel(nC1,nC2,nI1,nI2);
    
    params1(i,:) = params_tmp(1:4);
    params2(i,:) = params_tmp(5:8);
    
    % decide whether to use padding correction
    
    if abs(params1(i,4)) > 0.98
        padding1(i) = 1; % padding correction
    end
    
    if abs(params2(i,4)) > 0.98
        padding2(i) = 1; % padding correction
    end
    
    if padding1(i) ~= 0 || padding2(i) ~= 0
        [params_tmp,logL(i,1),predicted(i,:),warning(i,:)]=fit_bimBins_fullModel(nC1,nC2,nI1,nI2,padding1(i),padding2(i));
        params1(i,:) = params_tmp(1:4);
        params2(i,:) = params_tmp(5:8);
    end

    
end

params{1} = params1;
params{2} = params2;

padding = [padding1 padding2]; % whether padding correction is implemented in each condition for each participant