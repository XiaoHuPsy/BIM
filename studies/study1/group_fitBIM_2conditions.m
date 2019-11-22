function [params,err,warning] = group_fitBIM_2conditions(jol_data)
% fit BIM to JOL data (with 2 conditions) from a group of participants

subID = sort(unique(jol_data(:,1))); % ID for subject
conditionID = sort(unique(jol_data(:,2))); % ID for condition

nsubj = length(subID); % number of subjects

params1 = zeros(nsubj,4); % fitted parameters in condition 1
params2 = zeros(nsubj,4); % fitted parameters in condition 2
err = zeros(nsubj,2);
warning = zeros(nsubj,2);

for i = 1:nsubj
    
    jol_data_sub = jol_data(jol_data(:,1)==subID(i),:);
    jol_data_sub1 = jol_data_sub(jol_data_sub(:,2)==conditionID(1),:);
    jol_data_sub2 = jol_data_sub(jol_data_sub(:,2)==conditionID(2),:);
    
    [params1(i,:),err(i,1),warning(i,1)] = fit_bim(jol_data_sub1(:,3:4));
    
    if abs(params1(i,4)) > 0.98
        [params1(i,:),err(i,1),warning(i,1)] = fit_bim(jol_data_sub1(:,3:4),1); % padding correction
    end
    
    [params2(i,:),err(i,2),warning(i,2)] = fit_bim(jol_data_sub2(:,3:4));
    
    if abs(params2(i,4)) > 0.98
        [params2(i,:),err(i,2),warning(i,2)] = fit_bim(jol_data_sub2(:,3:4),1); % padding correction
    end
    
end

params{1} = params1;
params{2} = params2;