function fit_params_AUROC = recovery_AUROC(data,nratings)
% calculate AUROC for simulated datasets

sampleNum = size(data,3);
fit_params_AUROC = zeros(sampleNum,1); % AUROC

for i = 1:sampleNum
    
    observed_data = data(:,:,i);
    
    fit_params_AUROC(i) = type2roc(observed_data(:,2),observed_data(:,1),nratings);
    
end