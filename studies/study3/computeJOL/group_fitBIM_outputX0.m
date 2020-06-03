function [params,logL,warning,X0] = group_fitBIM_outputX0(jol_data)
% Fit BIM (applied to recall tasks with continuous confidence) to data from
% a group of participants. This function can output the value of X0 for
% each trial.

subID = sort(unique(jol_data(:,1)));
conditionID = sort(unique(jol_data(:,2)));

nsubj = length(subID);

params1 = zeros(nsubj,4);
params2 = zeros(nsubj,4);
logL = zeros(nsubj,2);
warning = zeros(nsubj,2);

X0_con1 = {};
X0_con2 = {};

for i = 1:nsubj
    
    jol_data_sub = jol_data(jol_data(:,1)==subID(i),:);
    jol_data_sub1 = jol_data_sub(jol_data_sub(:,2)==conditionID(1),:);
    jol_data_sub2 = jol_data_sub(jol_data_sub(:,2)==conditionID(2),:);
    
    [params1(i,:),logL(i,1),warning(i,1),X0_con1(i,:)] = fit_bim_outputX0(jol_data_sub1(:,3:4));
    
    if abs(params1(i,4)) > 0.98
        [params1(i,:),logL(i,1),warning(i,1),X0_con1(i,:)] = fit_bim_outputX0(jol_data_sub1(:,3:4),1);
    end
    
    [params2(i,:),logL(i,2),warning(i,2),X0_con2(i,:)] = fit_bim_outputX0(jol_data_sub2(:,3:4));
    
    if abs(params2(i,4)) > 0.98
        [params2(i,:),logL(i,2),warning(i,2),X0_con2(i,:)] = fit_bim_outputX0(jol_data_sub2(:,3:4),1);
    end
    
end

params{1} = params1;
params{2} = params2;

X0{1} = X0_con1;
X0{2} = X0_con2;

logL = logL(:,1) + logL(:,2);